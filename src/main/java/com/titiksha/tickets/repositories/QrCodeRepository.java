package com.titiksha.tickets.repositories;

import com.titiksha.tickets.domain.entities.QrCode;
import com.titiksha.tickets.domain.entities.QrCodeStatusEnum;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface QrCodeRepository extends JpaRepository<QrCode, UUID> {
  Optional<QrCode> findByTicketId(UUID ticketId);

  Optional<QrCode> findByTicketIdAndTicketPurchaserId(UUID ticketId, UUID purchaserId);

  Optional<QrCode> findByIdAndStatus(UUID id, QrCodeStatusEnum status);
}
