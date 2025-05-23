package com.ccc.ari.subscription.infrastructure.persistence.repository;

import com.ccc.ari.subscription.domain.Subscription;
import com.ccc.ari.subscription.infrastructure.persistence.entity.SubscriptionEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface SubscriptionJpaRepository extends JpaRepository<SubscriptionEntity, Integer> {
    
    List<SubscriptionEntity> findByMemberId(Integer memberId);
    List<SubscriptionEntity> findAllByMemberId(Integer memberId);
    Optional<List<SubscriptionEntity>> findByMemberIdAndSubscriptionPlanId(Integer memberId, Integer subscriptionPlanId);
    Integer countBySubscriptionPlanIdAndActivateYnIsTrue(Integer subscriptionPlanId);
    List<SubscriptionEntity> findAllBySubscriptionPlanIdAndActivateYnTrue(Integer subscriptionPlanId);
    List<SubscriptionEntity> findAllBySubscriptionPlanIdAndSubscribedAtBetweenAndActivateYnTrue
            (Integer subscriptionPlanId, LocalDateTime start, LocalDateTime end);
}
