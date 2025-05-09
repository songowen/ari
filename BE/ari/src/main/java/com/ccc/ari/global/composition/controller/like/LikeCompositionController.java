package com.ccc.ari.global.composition.controller.like;

import com.ccc.ari.community.application.like.command.LikeCommand;
import com.ccc.ari.community.ui.like.request.LikeRequest;
import com.ccc.ari.global.composition.service.like.AlbumTrackLikeService;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/albums")
@RequiredArgsConstructor
public class LikeCompositionController {

    private final AlbumTrackLikeService albumTrackLikeService;

    // 앨범 좋아요
    @PostMapping("/{albumId}/likes")
    public ApiUtils.ApiResponse<Void> updateAlbumLike(
            @PathVariable Integer albumId,
            @RequestBody LikeRequest request,
            @AuthenticationPrincipal MemberUserDetails userDetails) {

        Integer memberId = userDetails.getMemberId();
        LikeCommand command = request.toCommand(albumId, memberId);
        albumTrackLikeService.updateAlbumLike(command);

        return ApiUtils.success(null);
    }

    // 트랙 좋아요
    @PostMapping("/{albumId}/tracks/{trackId}/likes")
    public ApiUtils.ApiResponse<Void> updateTrackLike(
            @PathVariable Integer albumId,
            @PathVariable Integer trackId,
            @RequestBody LikeRequest request,
            @AuthenticationPrincipal MemberUserDetails userDetails) {

        Integer memberId = userDetails.getMemberId();
        LikeCommand command = request.toCommand(trackId, memberId);
        albumTrackLikeService.updateTrackLike(command);

        return ApiUtils.success(null);
    }
}
