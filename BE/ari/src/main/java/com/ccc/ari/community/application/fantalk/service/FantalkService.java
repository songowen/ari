package com.ccc.ari.community.application.fantalk.service;

import com.ccc.ari.community.application.fantalk.command.CreateFantalkCommand;
import com.ccc.ari.community.application.fantalk.repository.FantalkRepository;
import com.ccc.ari.global.infrastructure.S3Client;
import com.ccc.ari.community.domain.fantalk.entity.Fantalk;
import com.ccc.ari.community.domain.fantalk.vo.FantalkContent;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class FantalkService {

    private final FantalkRepository fantalkRepository;
    private static final Logger logger = LoggerFactory.getLogger(FantalkService.class);
    private final S3Client s3Client;

    @Transactional
    public void createFantalk(CreateFantalkCommand command) {
        // 1. 팬톡 이미지를 S3에 업로드합니다.
        String imageUrl = null;
        if (command.getFantalkImage() != null && !command.getFantalkImage().isEmpty()) {
            imageUrl = s3Client.uploadImage(command.getFantalkImage(), "fantalk");
        }

        // 2. 팬톡 내용을 담고 있는 값 객체를 생성합니다.
        FantalkContent contentVO = new FantalkContent(
                command.getContent(),
                command.getTrackId(),
                imageUrl
        );
        logger.info("팬톡 내용 VO 생성: {}", contentVO);

        // 3. 팬톡 도메인 엔티티를 생성합니다.
        Fantalk fantalk = Fantalk.builder()
                .fantalkChannelId(command.getFantalkChannelId())
                .memberId(command.getMemberId())
                .content(contentVO)
                .createdAt(LocalDateTime.now())
                .build();
        logger.info("팬톡 도메인 엔티티 생성: {}", fantalk);

        // 4. 팬톡을 저장합니다.
        Fantalk savedFantalk = fantalkRepository.saveFantalk(fantalk);
        logger.info("팬톡 저장 완료: fantalkId={}", savedFantalk.getFantalkId());
    }
}
