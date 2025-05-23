package com.ccc.ari.subscription.domain.repository;

import com.ccc.ari.global.type.EventType;
import com.ccc.ari.global.type.PlanType;

public interface SubscriptionEventRepository {

    boolean existsBySubscriptionEventIdAndEventTypeP(String subscriptionEventId);

    boolean existsBySubscriptionEventIdAndEventTypeS(String subscriptionEventId);

    boolean existsBySubscriptionEventIdAndEventType(String subscriptionEventId, EventType eventType);

    void save(String subscriptionEventId, EventType eventType, Integer subscriberId, PlanType planType);
}
