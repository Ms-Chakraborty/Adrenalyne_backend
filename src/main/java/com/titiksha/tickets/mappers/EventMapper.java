package com.titiksha.tickets.mappers;

import com.titiksha.tickets.domain.CreateEventRequest;
import com.titiksha.tickets.domain.CreateTicketTypeRequest;
import com.titiksha.tickets.domain.UpdateEventRequest;
import com.titiksha.tickets.domain.UpdateTicketTypeRequest;
import com.titiksha.tickets.domain.dtos.CreateEventRequestDto;
import com.titiksha.tickets.domain.dtos.CreateEventResponseDto;
import com.titiksha.tickets.domain.dtos.CreateTicketTypeRequestDto;
import com.titiksha.tickets.domain.dtos.GetEventDetailsResponseDto;
import com.titiksha.tickets.domain.dtos.GetEventDetailsTicketTypesResponseDto;
import com.titiksha.tickets.domain.dtos.GetPublishedEventDetailsResponseDto;
import com.titiksha.tickets.domain.dtos.GetPublishedEventDetailsTicketTypesResponseDto;
import com.titiksha.tickets.domain.dtos.ListEventResponseDto;
import com.titiksha.tickets.domain.dtos.ListEventTicketTypeResponseDto;
import com.titiksha.tickets.domain.dtos.ListPublishedEventResponseDto;
import com.titiksha.tickets.domain.dtos.UpdateEventRequestDto;
import com.titiksha.tickets.domain.dtos.UpdateEventResponseDto;
import com.titiksha.tickets.domain.dtos.UpdateTicketTypeRequestDto;
import com.titiksha.tickets.domain.dtos.UpdateTicketTypeResponseDto;
import com.titiksha.tickets.domain.entities.Event;
import com.titiksha.tickets.domain.entities.TicketType;
import org.mapstruct.Mapper;
import org.mapstruct.ReportingPolicy;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface EventMapper {

  CreateTicketTypeRequest fromDto(CreateTicketTypeRequestDto dto);

  CreateEventRequest fromDto(CreateEventRequestDto dto);

  CreateEventResponseDto toDto(Event event);

  ListEventTicketTypeResponseDto toDto(TicketType ticketType);

  ListEventResponseDto toListEventResponseDto(Event event);

  GetEventDetailsTicketTypesResponseDto toGetEventDetailsTicketTypesResponseDto(
      TicketType ticketType);

  GetEventDetailsResponseDto toGetEventDetailsResponseDto(Event event);

  UpdateTicketTypeRequest fromDto(UpdateTicketTypeRequestDto dto);

  UpdateEventRequest fromDto(UpdateEventRequestDto dto);

  UpdateTicketTypeResponseDto toUpdateTicketTypeResponseDto(TicketType ticketType);

  UpdateEventResponseDto toUpdateEventResponseDto(Event event);

  ListPublishedEventResponseDto toListPublishedEventResponseDto(Event event);

  GetPublishedEventDetailsTicketTypesResponseDto toGetPublishedEventDetailsTicketTypesResponseDto(
      TicketType ticketType);

  GetPublishedEventDetailsResponseDto toGetPublishedEventDetailsResponseDto(Event event);
}
