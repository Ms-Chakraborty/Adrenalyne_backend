package com.titiksha.tickets;

import java.util.TimeZone;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class TicketsApplication {

  public static void main(String[] args) {
    // Ensure a Postgres-compatible timezone name is used at JVM startup
    TimeZone.setDefault(TimeZone.getTimeZone("Asia/Kolkata"));
    SpringApplication.run(TicketsApplication.class, args);
  }

}
