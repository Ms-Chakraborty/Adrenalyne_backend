package com.titiksha.tickets.util;

import java.nio.charset.StandardCharsets;
import java.util.UUID;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.jwt.Jwt;

public final class JwtUtil {
  private JwtUtil(){
  }

  public static UUID parseUserId(Jwt jwt) {
    return UUID.fromString(jwt.getSubject());
  }

  public static UUID parseUserId(Authentication authentication) {
    Object principal = authentication.getPrincipal();
    if (principal instanceof Jwt jwt) {
      return parseUserId(jwt);
    }

    return UUID.nameUUIDFromBytes(("dev:" + authentication.getName()).getBytes(StandardCharsets.UTF_8));
  }


}
