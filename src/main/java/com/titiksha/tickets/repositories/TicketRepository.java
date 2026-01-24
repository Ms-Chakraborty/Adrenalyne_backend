package com.titiksha.tickets.repositories;

import com.titiksha.tickets.domain.entities.Ticket;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TicketRepository extends JpaRepository<Ticket, UUID> {
  Optional<Ticket> findByIdAndTicketTypeEventId(UUID id, UUID eventId);

  Page<Ticket> findByPurchaserId(UUID purchaserId, Pageable pageable);

  Optional<Ticket> findByIdAndPurchaserId(UUID id, UUID purchaserId);

  int countByTicketTypeId(UUID ticketTypeId);
}
