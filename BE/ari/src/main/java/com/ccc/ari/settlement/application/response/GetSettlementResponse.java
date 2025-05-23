package com.ccc.ari.settlement.application.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
@Builder
public class GetSettlementResponse {

    private final String regularSettlement;
    private final String artistSettlement;
}
