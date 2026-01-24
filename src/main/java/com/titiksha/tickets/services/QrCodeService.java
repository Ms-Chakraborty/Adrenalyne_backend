package com.titiksha.tickets.services;

import com.titiksha.tickets.domain.entities.QrCode;
import com.titiksha.tickets.domain.entities.Ticket;
import java.util.UUID;

public interface QrCodeService {

  QrCode generateQrCode(Ticket ticket);

  byte[] getQrCodeImageForUserAndTicket(UUID userId, UUID ticketId);
}
