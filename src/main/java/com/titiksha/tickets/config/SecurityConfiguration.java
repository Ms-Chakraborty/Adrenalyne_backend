package com.titiksha.tickets.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.Collection;
import java.util.Map;
import java.util.Collections;
import java.util.stream.Collectors;

import org.springframework.core.convert.converter.Converter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.core.env.Environment;
import org.springframework.core.env.Profiles;
import org.springframework.context.annotation.Profile;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@Configuration
@EnableWebSecurity
public class SecurityConfiguration {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http, Environment env) throws Exception {
        boolean isDev = env.acceptsProfiles(Profiles.of("dev"));

        // Common authorizations
        http = http.cors(Customizer.withDefaults()).csrf(csrf -> csrf.disable());

        http.authorizeHttpRequests(auth -> auth
            // Allow unauthenticated access to the dev SPA auth endpoints
            .requestMatchers("/api/v1/auth/**").permitAll()
            .requestMatchers("/api/v1/published-events/**").permitAll()
            // Allow authenticated users to purchase tickets
            .requestMatchers(HttpMethod.POST, "/api/v1/events/*/ticket-types/*/tickets").authenticated()
            // Organizer-only event management endpoints
            .requestMatchers("/api/v1/events/**").hasAuthority("ROLE_ADMIN")
            .requestMatchers("/api/v1/ticket-validations/**").hasAuthority("ROLE_VALIDATOR")
            .anyRequest().authenticated()
        );

        if (isDev) {
            // Simple dev authentication: form login + basic
            http = http.formLogin(Customizer.withDefaults()).httpBasic(Customizer.withDefaults());
        } else {
            // Production: resource server (Keycloak/OIDC)
            http = http.oauth2ResourceServer(oauth2 -> oauth2.jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthenticationConverter())));
        }

        return http.build();
    }

    // This converts Auth0 "roles" claim into Spring Security authorities
@Bean
public JwtAuthenticationConverter jwtAuthenticationConverter() {
    JwtAuthenticationConverter jwtConverter = new JwtAuthenticationConverter();

    jwtConverter.setJwtGrantedAuthoritiesConverter(new Converter<Jwt, Collection<GrantedAuthority>>() {
        @Override
        public Collection<GrantedAuthority> convert(Jwt jwt) {
            // 1. Get the realm_access object from Keycloak token
            Map<String, Object> realmAccess = jwt.getClaim("realm_access");
            if (realmAccess == null || realmAccess.isEmpty()) {
                return Collections.emptyList();
            }
            
            // 2. Get the roles list from inside realm_access
            Collection<String> roles = (Collection<String>) realmAccess.get("roles");
            if (roles == null) {
                return Collections.emptyList();
            }
            
                // 3. Map them to Spring Authorities with "ROLE_" prefix (uppercase)
                return roles.stream()
                    .map(role -> new SimpleGrantedAuthority("ROLE_" + role.toString().toUpperCase()))
                    .collect(Collectors.toList());
        }
    });

    return jwtConverter;
}

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList(
            "https://adreanalyne-frontend-fzhs.vercel.app",
            "http://localhost:5173",
            "http://localhost:5174"
        ));
        // Add common dev origins so local frontends and Keycloak can interact
        configuration.getAllowedOrigins().addAll(Arrays.asList(
            "http://localhost:3000",
            "http://localhost:8080",
            "http://localhost:9090"
        ));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"));
        configuration.setAllowedHeaders(Arrays.asList("Authorization", "Content-Type", "Accept", "Origin"));
        configuration.setAllowCredentials(true);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    // Dev-only: simple in-memory users for local development
    @Bean
    @Profile("dev")
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    @Profile("dev")
    public InMemoryUserDetailsManager inMemoryUserDetailsManager(PasswordEncoder passwordEncoder) {
        UserDetails admin = User.withUsername("admin").password(passwordEncoder.encode("AdminPass123!")).roles("ADMIN").build();
        UserDetails attendee = User.withUsername("attendee").password(passwordEncoder.encode("AttendeePass123!")).roles("ATTENDEE").build();
        UserDetails validator = User.withUsername("validator").password(passwordEncoder.encode("ValidatorPass123!")).roles("VALIDATOR").build();
        return new InMemoryUserDetailsManager(admin, attendee, validator);
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }

}