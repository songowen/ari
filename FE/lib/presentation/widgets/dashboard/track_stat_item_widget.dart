import 'package:ari/data/models/dashboard/track_stats_model.dart';
import 'package:ari/presentation/viewmodels/dashboard/track_stat_list_viewmodel.dart';
import 'package:flutter/material.dart';

class TrackStatItem extends StatelessWidget {
  final TrackStats trackStat;
  final int index;

  const TrackStatItem({
    super.key,
    required this.trackStat,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 10, 20, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 순위 번호
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 트랙 이미지
          Container(
            width: 70,
            height: 70,
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: NetworkImage(trackStat.coverImageUrl),
                fit: BoxFit.cover,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 트랙 정보
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 트랙 제목
                Text(
                  trackStat.trackTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                // 재생 정보
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 월간 재생 수
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text(
                          '월간 재생 수',
                          style: TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontSize: 12,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${trackStat.monthlyStreamingCount}',
                          style: const TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontSize: 12,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 누적 재생 수
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '누적 재생 수',
                          style: TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontSize: 12,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${trackStat.totalStreamingCount}',
                          style: const TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontSize: 12,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SortButton extends StatelessWidget {
  final SortBy sortBy;
  final VoidCallback onPressed;

  const SortButton({super.key, required this.sortBy, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
        child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            sortBy == SortBy.totalStreamingCount ? '누적 재생 수' : '월간 재생 수',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4), // 간격 추가
          Transform.rotate(
            angle: 1.57,
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFD9D9D9),
              size: 18,
            ),
          ),
          ],
        ),
      ),
    );
  }
}