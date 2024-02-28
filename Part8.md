# Part 8 - JWT

<!--toc:start-->

- [JWT](#jwt)
  - [What JWT](#what-jwt)
  - [How JWT](#how-jwt)
  - [SecurityConfig](#securityconfig)
  - [CustomUserDetailsService](#customuserdetailsservice)
    - [AuthTokenFilter](#authtokenfilter)
    - [JwtUtils](#jwtutils)
    - [JwtResponse](#jwtresponse)
    - [AuthController](#authcontroller)
    - [Variables](#variables)
- [Postman](#postman)
<!--toc:end-->

## JWT

This is entirely optional, but it doesn't take that long.

### What JWT

No better place than the [docs](https://jwt.io/) for that tbh.

Also, it's a way to add some security by changing the way payloads are sent through
two parties.
The sent claim is encoded as a JSON payload of a JSON Web Signature.
It consists of the following:

- Header
  - Type of token (JWT)
  - Sign algorithm (Usually HMAC, SHA256 or RSA).
- Payload
  - Claims: registered/public/private.
- Signature
  - Once the header, payload and things like the secret are encoded, the signature is our verification to ensure the sender is actually the sender.
  - Also helps to make sure the message wasn't modified sometime during transaction.

Basically authentication with extra (actually less) steps.
Really lightweight since it can be sent through URL, POST parameters or a HTTP header.

### How JWT

Add the dependency on your `build.gradle` or `pom.xml`.

```java
dependencies {
  // this is a security spring dependency
  implementation 'org.springframework.boot:spring-boot-starter-security'

  implementation 'io.jsonwebtoken:jjwt-api:0.12.5'
  runtimeOnly 'io.jsonwebtoken:jjwt-impl:0.12.5'
  runtimeOnly 'io.jsonwebtoken:jjwt-jackson:0.12.5'
}
```

Refresh the project and start the application.
By now you should see a small change in your console output:

```json
{
  Using generated security password: {PASSWORD_STRING}
}
```

This means our security dependency is doing things properly.
The default auth process is through login.

Access your development url and paste in that password.
The default user is `user`.

Check [this article](https://www.toptal.com/spring/spring-security-tutorial)
for more info.

### SecurityConfig

We need a class to handle security in our application.
In it we'll give it context to a new `UserDetailsService` class and an `AuthTokenFilter`
With the `@Configuration` annotation spring will know it's required to function.

We'll add this class inside a special `security` package

- SecurityConfig

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
  @Autowired
  private UserDetailsService userDetailsService;

  @Autowired
  private AuthTokenFilter authTokenFilter;

  @Bean
  public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
    return authenticationConfiguration.getAuthenticationManager();
  }

  // This method is cool
  // It will control authentication through our endpoints.
  @Bean
  public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    http
      .csrf(csrf -> csrf.disable())
      .authorizeHttpRequests(authorize -> authorize
        .requestMatchers(HttpMethod.POST, "/api/auth/**").permitAll()
        .requestMatchers(HttpMethod.GET, "/api/**").permitAll() // optional
        .anyRequest().authenticated()
      )
      .addFilterBefore(authenticationJwtTokenFilter(), UsernamePasswordAuthenticationFilter.class);
    return http.build();
  }

  @Bean
  public AuthTokenFilter authenticationJwtTokenFilter() {
    return authTokenFilter;
  }

  @Bean
  public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
  }

}
```

### CustomUserDetailsService

We need a custom `UserDetailsService` class in order to load our users details.
This is to implement pre-configured methods to create a user as a DAO entity.

```java
@Service
public class CustomUserDetailsService implements UserDetailsService {
  @Autowired
  private UserRepository userRepository;

  @Override
  public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
    User user = userRepository.findByUsername(username)
    .orElseThrow(() -> new UsernameNotFoundException("Username not found"));

    return org.springframework.security.core.userdetails.User
    .withUsername(user.getUsername())
    .password(user.getPassword())
    .authorities(new ArrayList<>())
    .accountExpired(false)
    .accountLocked(false)
    .credentialsExpired(false)
    .disabled(false)
    .build();
  }
}
```

#### AuthTokenFilter

This utility class will aid in filtering users' requests through a verification procedure.
As such, place it inside an `utils` package.

```java
@Component
public class AuthTokenFilter extends OncePerRequestFilter {
  @Autowired
  JwtUtils jwtUtils;

  @Autowired
  private CustomUserDetailsService userDetailsService;

  @Override
  protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
  throws ServletException, IOException {
    try {
      String jwt = parseJwt(request);
      if (jwt != null && jwtUtils.validateJwtToken(jwt)) {
        String username = jwtUtils.getUserNameFromJwtToken(jwt);
        UserDetails userDetails = userDetailsService.loadUserByUsername(username);
        UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(authentication);
      }
    } catch (Exception e) {
      logger.error("Cannot set user authentication: {}", e);
    }
    filterChain.doFilter(request, response);
  }

  private String parseJwt(HttpServletRequest request) {
    String headerAuth = request.getHeader("Authorization");
    return (headerAuth != null && headerAuth.startsWith("Bearer "))
    ? headerAuth.substring(7) : null;
  }
}
```

As you can see, here we implement methods from our `userDetailsService`.

This works similarly as other services, but methods come directly from:
.springframework.security.

#### JwtUtils

We require some utility methods from Jwt.
We already implement some of them here, but we need a couple more to make things work.

Specifically, we need utility methods to get the data from the `signed token`,
and validate our `JWT` in order to confirm the payload.

```java
@Component
public class JwtUtils {
  // remember these two
	@Value("${app.jwtSecret}")
	private String jwtSecret;

	@Value("${app.jwtExpirationMs}")
	private int jwtExpirationMS;

	public String generateJwtToken(Authentication authentication) {
		String username = authentication.getName();
		SecretKey key = Jwts.SIG.HS256.key().build();
		return Jwts.builder().subject(username).issuedAt(new Date())
				.expiration(new Date((new Date()).getTime() + jwtExpirationMS))
				.signWith(key).compact();
	}

	@Deprecated
	public String getUserNameFromJwtToken(String token) {
		Claims claims = Jwts.parser().setSigningKey(token).build().parseClaimsJws(token).getBody();
		return claims.getSubject();
	}

	@Deprecated
	public boolean validateJwtToken(String authToken) {
		try {
			Jwts.parser().setSigningKey(jwtSecret).build().parseClaimsJws(authToken);
			return true;
		} catch (Exception e) {
			// errs
		}
		return false;
	}
}
```

In here we setup a couple of environment values:
`${app.jwtSecret}` and `${app.jwtExpirationMs}` for our development env.
You might need to change those in prod tho.

Then we have three methods.

- `generateJwtToken`
  - This does precisely what it claims
- `getUserNameFromJwtToken`
  - From the signed token, it handles the username.
- `validateJwtToken`
  - Just makes sure it makes sense and is as per our APIs requirements.

#### JwtResponse

The response must first be built in order to send it back to the client.
Since this is an entity, just make a small model for this class.
Don't forget getters, setters and constructors.

```java
public class JwtResponse {
  private String token;
  private String type = "Bearer";
}
```

#### AuthController

We'll handle authentication on its own controller since SOLID and stuff.

```java
@RestController
@RequestMapping("/api/auth")
public class AuthController {
	@Autowired
	AuthenticationManager authenticationManager;

	@Autowired
	JwtUtils jwtUtils;

	@PostMapping("/login")
	public ResponseEntity<?> authenticateUser(@RequestParam("username") String username, @RequestParam("password") String password) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(username, password));

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = jwtUtils.generateJwtToken(authentication);

        return ResponseEntity.ok(new JwtResponse(jwt));
    }
}
```

This endpoint will handle our authentication process when the user logs in.
For logout, you should/could handle it here as well since it falls within the same context.

#### Variables

`Jwt` requires a `secret key` for your application.
This `secret`, alongside the `data` will create a `signature`.
This `signature`, plus the `payload` and `header` make a `JWT`.

Or at least that's what I understood.

Anyway, what we want is a `signed JWT`.
With this, and only with this, can we make sure the request hasn't been corrupted
or altered in any way.

For simplicity's sake, our `secret` will be inside `application.properties`.

Go to any online resource and create a secret key with base 64 (recommended).

You can also make it inside your terminal with:

```sh
openssl rand -base64 64
```

It should look something like a big a$$ string.

Paste it inside `application.properties` like so:

```xml
app.jwtSecret={SECRET_HERE}
app.jwtExpirationMs={EXPIRATION_IN_MS_HERE}
```

Take note the expiration for the JWT is in milliseconds,
so for a day of expiration the value would be: **86400000**

## Postman

Run the project. Save everything before you run it, then run it.

With postman you should be able to make a `POST` request to the auth url:

- METHOD: POST
- URL: localhost:{PORT}/api/auth/login
- BODY:

```json
{
  "username": "username",
  "password": "password"
}
```

And if your user is saved in the database, the returned body will be a `json` in the form of:

```json
{
  "token": "${BIG_String_Here}",
  "type": "Bearer"
}
```

And that's it for JWT. You've now authenticated a payload.

Store this `token` somewhere safe for the client to use (but actually no).
When the user makes a request to any other url make sure
its inside the "Authorization" header attribute of the request.

```js
const token = "your_jwt_token"; // Assume you've stored your token here

fetch("http://localhost:8080/api/protected-endpoint", {
  method: "GET", // or 'POST', 'PUT', 'DELETE', etc.
  headers: {
    Authorization: `Bearer ${token}`,
    "Content-Type": "application/json",
  },
})
  .then((response) => response.json())
  .then((data) => console.log(data))
  .catch((error) => console.error("Error:", error));
```

GLHF;
