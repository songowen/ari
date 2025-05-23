package com.ccc.ari.subscription.application.service;

import com.ccc.ari.subscription.domain.repository.SubscriptionPlanRepository;
import com.ccc.ari.subscription.domain.SubscriptionPlan;
import com.ccc.ari.subscription.domain.service.SubscriptionPlanManageService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
public class SubscriptionPlanPersistenceService {

    private final SubscriptionPlanManageService subscriptionPlanManageService;
    private final SubscriptionPlanRepository subscriptionPlanRepository;

    @Transactional
    public void createRegularSubscriptionPlan(BigDecimal price) {
        SubscriptionPlan regularSubscriptionPlan =
                subscriptionPlanManageService.createRegularSubscriptionPlan(price);
        subscriptionPlanRepository.save(regularSubscriptionPlan);
    }

    @Transactional
    public SubscriptionPlan createArtistSubscriptionPlan(Integer artistId, BigDecimal price) {
        SubscriptionPlan artistSubscriptionPlan =
                subscriptionPlanManageService.createArtistSubscriptionPlan(artistId, price);
        return subscriptionPlanRepository.save(artistSubscriptionPlan);
    }
}
