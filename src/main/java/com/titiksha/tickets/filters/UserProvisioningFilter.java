package com.titiksha.tickets.filters;

import com.titiksha.tickets.domain.entities.User;
import com.titiksha.tickets.repositories.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
@RequiredArgsConstructor
public class UserProvisioningFilter extends OncePerRequestFilter {

  private final UserRepository userRepository;

  @Override
  protected void doFilterInternal(
      HttpServletRequest request,
      HttpServletResponse response,
      FilterChain filterChain) throws ServletException, IOException {

    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

    if (authentication != null && authentication.isAuthenticated()) {
      UUID userId;
      String username;
      String email;

      if (authentication.getPrincipal() instanceof Jwt jwt) {
        userId = UUID.fromString(jwt.getSubject());
        username = jwt.getClaimAsString("preferred_username");
        email = jwt.getClaimAsString("email");
      } else {
        username = authentication.getName();
        userId = UUID.nameUUIDFromBytes(("dev:" + username).getBytes(StandardCharsets.UTF_8));
        email = username + "@local.dev";
      }

      if (!userRepository.existsById(userId)) {
        User user = new User();
        user.setId(userId);
        user.setName(username);
        user.setEmail(email);

        userRepository.save(user);
      }

    }

    filterChain.doFilter(request, response);
  }
}
