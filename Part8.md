# Part 8 - JWT

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

### Security class

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
