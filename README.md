# 🎵 Ari - 블록체인 기반 음원 스트리밍 플랫폼

> 불투명한 정산과 복잡한 음원 등록 과정을 개선하기 위한 **탈중앙화 음원 플랫폼**  
> 투명한 스트리밍 데이터와 자동화된 정산 시스템으로 아티스트와 사용자 모두에게 공정한 생태계를 제공합니다.

---

## 🧩 문제 정의

기존 음원 플랫폼은 다음과 같은 문제를 안고 있습니다:

- ❌ 불투명한 스트리밍 데이터  
- ❌ 불공정한 수익 정산 구조  
- ❌ 복잡하고 제한적인 음원 등록 과정  
- ❌ 불법 사재기 및 조회수 조작 문제  

---

## 💡 Ari의 해결방안

Ari는 블록체인의 **투명성, 불변성, 탈중앙화** 특성을 활용하여 아래와 같은 기능을 구현합니다.

| 기능 | 설명 |
|------|------|
| 🔎 투명한 스트리밍 데이터 | IPFS + Merkle Tree를 통한 검증 가능한 데이터 |
| 💰 공정한 정산 시스템 | 스마트 컨트랙트를 활용한 온체인 정산 |
| 🚀 간편한 음원 등록 | 누구나 몇 번의 클릭으로 음원 등록 가능 |
| 🔄 자동화된 정산 | Chainlink Automation을 통한 구독 기반 정산 자동화 |

---

## 🔧 기술 구성

### 📦 아키텍처 요약
  
  ---

### 🧱 주요 기술 스택

| 구분 | 기술 |
|------|------|
| 클라이언트 | Flutter, Hive, just_audio |
| 서버 | Spring Boot, MySQL, MongoDB, Redis |
| 인프라 | Docker, Nginx, Jenkins |
| 기타 | Figma, Postman, Gitlab |
| 분산 저장 | IPFS |
| 블록체인 | Ethereum (Testnet), Merkle Tree 구조 |
| 기타 | Chainlink Automation (오라클 자동 트리거) |

---

### ⛓️ 온체인 vs 오프체인 전략

- **온체인**: 정산 내역, Merkle Root, 토큰 트랜잭션  
- **오프체인**: 대용량 스트리밍 로그, 사용자 음원 파일

---

## ⚙️ 성능 개선

- 기존 스트리밍 내역 조회 시간: 평균 **46초**
- 개선 후 핀닝 + 비동기 처리: 평균 **8초**  
  → `CompletableFuture` 구조 도입으로 응답 속도 대폭 개선

---

## 👥 팀 구성

### 🎧 Ari 팀

<table>
  <tbody>
    <tr align="center">
      <td><img src="https://avatars.githubusercontent.com/u/113484236?v=4" width="100px;" alt=""/><br /></td>
      <td><img src="https://avatars.githubusercontent.com/u/108385400?v=4" width="100px;" alt=""/><br /></td>
      <td><img src="https://avatars.githubusercontent.com/u/174885052?v=4" width="100px;" alt=""/><br /></td>
      <td><img src="https://avatars.githubusercontent.com/u/175234691?v=4" width="100px;" alt=""/><br /></td>
      <td><img src="https://avatars.githubusercontent.com/u/145769307?v=4" width="100px;" alt=""/><br /></td>
      <td><img src="https://avatars.githubusercontent.com/u/101163507?v=4" width="100px;" alt=""/><br /></td>
    </tr>
    <tr align="center">
      <td width="200"><a href="http://github.com/miltonjskim">팀장 : 김준석<br/>INFJ</a></td>
      <td width="200"><a href="http://github.com/wjdrbgus8167">팀원 : 정규현<br/>ISFP</a></td>
      <td width="200"><a href="https://github.com/kingkang85">팀원 : 강지민<br/>ISTP</a></td>
      <td width="200"><a href="https://github.com/naemhui">팀원 : 권남희<br/>ENFP</a></td>
      <td width="200"><a href="https://github.com/songowen">팀원 : 송창현<br/>ISTP</a></td>
      <td width="200"><a href="https://github.com/jinwooseok">팀원 : 진우석<br/>ENTJ</a></td>
    </tr>
    <tr align="center" height="200">
      <td>온체인 정산 설계 및 구현<br>Redis, IPFS, 스마트컨트랙트<br>Chainlink 오토메이션</td>
      <td>시각화 / 디자인 구조 설계<br>정산 시각 자료 구성</td>
      <td>블록체인 인프라 구성<br>IPFS 데이터 구조 및 처리<br>CID, Merkle Tree 저장</td>
      <td>프론트엔드 UI/UX 디자인<br>스트리밍 화면 / 구독 구조</td>
      <td>프론트엔드 전체 구조 설계<br>IPFS 스트리밍 내역 처리<br>React 기반 구현</td>
      <td>프론트엔드 문서 작성<br>페이지 구성 정리 및 README</td>
    </tr>
  </tbody>
</table>

---
