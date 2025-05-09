// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenZeppelin Ownable 및 SafeERC20 사용
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// Chainlink Automation 사용을 위한 인터페이스 추가
// 로컬 인터페이스 파일 사용
import "./AutomationCompatibleInterface.sol";

contract SubscriptionContract is Ownable, AutomationCompatibleInterface {
    using SafeERC20 for IERC20;

    struct RegularSubscription {
        uint256 startDate;       // 구독 시작일
        uint256 amount;          // 매달 청구할 금액
        uint256 lastPaymentTime; // 마지막 결제 시간
        uint256 interval;        // 결제 간격(초 단위, 보통 30일)
        bool active;             // 구독 활성화 상태
        address tokenAddress;    // 결제에 사용할 토큰 컨트랙트 주소
    }

    // 아티스트 구독 구조체
    struct ArtistSubscription {
        uint256 startDate;       // 구독 시작일
        uint256 amount;          // 매달 청구할 금액
        uint256 lastPaymentTime; // 마지막 결제 시간
        uint256 interval;        // 결제 간격
        bool active;             // 구독 활성화 상태
        address tokenAddress;    // 결제에 사용할 토큰 컨트랙트 주소
    }

    // 기본 구독 금액 및 기간 (관리자만 설정 가능)
    uint256 public defaultRegularAmount;
    uint256 public defaultRegularInterval;
    uint256 public defaultArtistAmount;
    uint256 public defaultArtistInterval;
    address public defaultTokenAddress;

    // 사용자 ID => 정기구독 정보
    mapping(uint256 => RegularSubscription) public regularSubscriptions;

    // 구독자 ID => 아티스트 ID => 아티스트 구독 정보
    mapping(uint256 => mapping(uint256 => ArtistSubscription)) public artistSubscriptions;

    // 사용자 ID => 사용자 주소
    mapping(uint256 => address) public userAddresses;

    // 사용자 주소 => 사용자 ID
    mapping(address => uint256) public addressToUserId;

    // 아티스트 ID => 아티스트 주소
    mapping(uint256 => address) public artistAddresses;

    // 각 아티스트를 구독한 구독자 ID 목록
    mapping(uint256 => uint256[]) public artistSubscribers;

    // 각 사용자가 구독한 아티스트 ID 목록
    mapping(uint256 => uint256[]) public userSubscribedArtists;

    // Chainlink Automation을 위한 데이터 구조
    // 모든 활성 정기 구독 사용자 ID 목록
    uint256[] public activeRegularSubscribers;
    // 정기 구독 사용자 ID => 활성 구독자 배열 내 인덱스
    mapping(uint256 => uint256) public regularSubscriberIndex;

    // 모든 활성 아티스트 구독 정보 배열 (구독자ID, 아티스트ID 쌍)
    struct ArtistSubscriptionPair {
        uint256 subscriberId;
        uint256 artistId;
    }
    ArtistSubscriptionPair[] public activeArtistSubscriptions;
    // 구독자ID, 아티스트ID 쌍 => 활성 구독 배열 내 인덱스
    mapping(uint256 => mapping(uint256 => uint256)) public artistSubscriptionIndex;

    // 한 번의 upkeep에서 처리할 최대 구독 수
    uint256 public constant MAX_UPKEEP_SUBSCRIPTIONS = 10;

    // 기본 이벤트들
    event RegularSubscriptionCreated(uint256 userId, uint256 amount, uint256 interval);
    event RegularSubscriptionCancelled(uint256 userId);
    event ArtistSubscriptionCreated(uint256 subscriberId, uint256 artistId, uint256 amount, uint256 interval);
    event ArtistSubscriptionCancelled(uint256 subscriberId, uint256 artistId);
    event PaymentProcessedRegular(uint256 userId, address tokenAddress, uint256 amount);
    event PaymentProcessedArtist(uint256 userId, uint256 artistId, address tokenAddress, uint256 amount);
    event UserRegistered(uint256 userId, address userAddress);
    event ArtistRegistered(uint256 artistId, address artistAddress);
    event SubscriptionSettingsUpdated(uint256 regularAmount, uint256 regularInterval, uint256 artistAmount, uint256 artistInterval, address tokenAddress);

    // 정산 관련 이벤트
    event SettlementRequestedRegular(uint256 indexed userId, uint256 periodStart, uint256 periodEnd, uint256 amount);
    event SettlementRequestedArtist(uint256 indexed subscriberId, uint256 artistId, uint256 periodStart, uint256 periodEnd, uint256 amount);
    event SettlementExecutedRegular(uint256 indexed userId, uint256 indexed artistId, uint256 indexed cycleId, uint256 amount, uint256 streamingCount);
    event SettlementExecutedArtist(uint256 indexed userId, uint256 indexed artistId, uint256 indexed cycleId, uint256 amount);

    constructor(
        uint256 _regularAmount,
        uint256 _regularInterval,
        uint256 _artistAmount,
        uint256 _artistInterval,
        address _tokenAddress
    ) Ownable(msg.sender) {
        defaultRegularAmount = _regularAmount;
        defaultRegularInterval = _regularInterval;
        defaultArtistAmount = _artistAmount;
        defaultArtistInterval = _artistInterval;
        defaultTokenAddress = _tokenAddress;
    }

    // 관리자가 구독 설정 업데이트
    function updateSubscriptionSettings(
        uint256 _regularAmount,
        uint256 _regularInterval,
        uint256 _artistAmount,
        uint256 _artistInterval,
        address _tokenAddress
    ) external onlyOwner {
        defaultRegularAmount = _regularAmount;
        defaultRegularInterval = _regularInterval;
        defaultArtistAmount = _artistAmount;
        defaultArtistInterval = _artistInterval;
        defaultTokenAddress = _tokenAddress;

        emit SubscriptionSettingsUpdated(_regularAmount, _regularInterval, _artistAmount, _artistInterval, _tokenAddress);
    }

    // 사용자 등록
    function registerUser(uint256 userId) external {
        require(addressToUserId[msg.sender] == 0, "Address already registered");
        require(userAddresses[userId] == address(0), "User ID already taken");

        userAddresses[userId] = msg.sender;
        addressToUserId[msg.sender] = userId;

        emit UserRegistered(userId, msg.sender);
    }

    // 아티스트 등록
    function registerArtist(uint256 artistId) external {
        require(artistAddresses[artistId] == address(0), "Artist ID already taken");

        artistAddresses[artistId] = msg.sender;

        emit ArtistRegistered(artistId, msg.sender);
    }

    // 정기구독 신청 (관리자 설정 기본값 사용)
    // 결제 시 토큰은 owner가 아닌 컨트랙트로 송금됨
    function subscribeRegular(uint256 userId) external {
        require(userAddresses[userId] == msg.sender, "Only user can subscribe");
        require(defaultRegularAmount > 0, "Subscription amount not set");
        require(defaultRegularInterval > 0, "Subscription interval not set");

        // 기존 구독은 덮어씌움
        regularSubscriptions[userId] = RegularSubscription({
            startDate: block.timestamp,
            amount: defaultRegularAmount,
            lastPaymentTime: block.timestamp,
            interval: defaultRegularInterval,
            active: true,
            tokenAddress: defaultTokenAddress
        });

        // 활성 정기 구독 목록에 추가
        _addToRegularSubscriberList(userId);

        // 첫 결제 처리: 사용자의 토큰을 컨트랙트로 송금
        IERC20(defaultTokenAddress).safeTransferFrom(msg.sender, address(this), defaultRegularAmount);

        emit RegularSubscriptionCreated(userId, defaultRegularAmount, defaultRegularInterval);
    }

    // 아티스트 구독 신청 (관리자 설정 기본값 사용)
    // 결제 시 토큰은 컨트랙트로 송금됨
    function subscribeToArtist(uint256 subscriberId, uint256 artistId) external {
        require(userAddresses[subscriberId] == msg.sender, "Only subscriber can subscribe");
        require(artistAddresses[artistId] != address(0), "Artist not registered");
        require(defaultArtistAmount > 0, "Subscription amount not set");
        require(defaultArtistInterval > 0, "Subscription interval not set");

        // 신규 구독인 경우에만 배열에 추가
        if (!artistSubscriptions[subscriberId][artistId].active) {
            artistSubscribers[artistId].push(subscriberId);
            userSubscribedArtists[subscriberId].push(artistId);

            // 활성 아티스트 구독 목록에 추가
            _addToArtistSubscriptionList(subscriberId, artistId);
        }

        // 구독 정보 업데이트
        artistSubscriptions[subscriberId][artistId] = ArtistSubscription({
            startDate: block.timestamp,
            amount: defaultArtistAmount,
            lastPaymentTime: block.timestamp,
            interval: defaultArtistInterval,
            active: true,
            tokenAddress: defaultTokenAddress
        });

        // 첫 결제 처리: 사용자의 토큰을 컨트랙트로 송금
        IERC20(defaultTokenAddress).safeTransferFrom(msg.sender, address(this), defaultArtistAmount);

        emit ArtistSubscriptionCreated(subscriberId, artistId, defaultArtistAmount, defaultArtistInterval);
    }

    // 정기구독 취소
    function cancelRegularSubscription(uint256 userId) external {
        require(userAddresses[userId] == msg.sender || msg.sender == owner(), "Only user or owner can cancel");
        require(regularSubscriptions[userId].active, "No active subscription");

        regularSubscriptions[userId].active = false;

        // 활성 정기 구독 목록에서 제거
        _removeFromRegularSubscriberList(userId);

        emit RegularSubscriptionCancelled(userId);
    }

    // 아티스트 구독 취소: 취소 시 관련 배열에서 해당 구독 정보를 제거
    function cancelArtistSubscription(uint256 subscriberId, uint256 artistId) external {
        require(userAddresses[subscriberId] == msg.sender || msg.sender == owner(), "Only subscriber or owner can cancel");
        require(artistSubscriptions[subscriberId][artistId].active, "No active subscription");

        artistSubscriptions[subscriberId][artistId].active = false;

        // artistSubscribers 배열에서 subscriberId 제거
        _removeFromArray(artistSubscribers[artistId], subscriberId);
        // userSubscribedArtists 배열에서 artistId 제거
        _removeFromArray(userSubscribedArtists[subscriberId], artistId);

        // 활성 아티스트 구독 목록에서 제거
        _removeFromArtistSubscriptionList(subscriberId, artistId);

        emit ArtistSubscriptionCancelled(subscriberId, artistId);
    }

    // 정기구독 결제 처리 (내부 함수)
    function _processRegularPayment(uint256 userId) internal returns (bool) {
        RegularSubscription storage sub = regularSubscriptions[userId];
        if (!sub.active) return false;

        // 다음 결제 시간인지 확인
        uint256 nextPaymentTime = sub.lastPaymentTime + sub.interval;
        if (block.timestamp < nextPaymentTime) return false;

        // 결제 전, 구독 기간에 대한 정산 요청 이벤트 발생
        emit SettlementRequestedRegular(userId, sub.lastPaymentTime, nextPaymentTime, sub.amount);

        IERC20 token = IERC20(sub.tokenAddress);
        // low-level call을 통해 transferFrom 호출
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(token.transferFrom.selector, userAddresses[userId], address(this), sub.amount)
        );
        // 반환값 검사: data가 없거나 true를 반환하면 성공
        bool transferSuccess = success && (data.length == 0 || abi.decode(data, (bool)));

        if (transferSuccess) {
            sub.lastPaymentTime = block.timestamp;
            emit PaymentProcessedRegular(userId, sub.tokenAddress, sub.amount);
            return true;
        } else {
            // 결제 실패 시 구독 취소 처리
            sub.active = false;
            _removeFromRegularSubscriberList(userId);
            emit RegularSubscriptionCancelled(userId);
            return false;
        }
    }

    // 아티스트 구독 결제 처리 (내부 함수)
    function _processArtistPayment(uint256 subscriberId, uint256 artistId) internal returns (bool) {
        ArtistSubscription storage sub = artistSubscriptions[subscriberId][artistId];
        if (!sub.active) return false;

        // 다음 결제 시간인지 확인
        uint256 nextPaymentTime = sub.lastPaymentTime + sub.interval;
        if (block.timestamp < nextPaymentTime) return false;

        // 결제 전, 구독 기간에 대한 정산 요청 이벤트 발생
        emit SettlementRequestedArtist(subscriberId, artistId, sub.lastPaymentTime, nextPaymentTime, sub.amount);

        IERC20 token = IERC20(sub.tokenAddress);
        // low-level call을 사용하여 transferFrom 호출
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSelector(token.transferFrom.selector, userAddresses[subscriberId], address(this), sub.amount)
        );
        // ERC20 함수의 반환값 확인: 데이터가 없거나, true를 반환하는 경우 성공
        bool transferSuccess = success && (data.length == 0 || abi.decode(data, (bool)));

        if (transferSuccess) {
            sub.lastPaymentTime = block.timestamp;
            emit PaymentProcessedArtist(subscriberId, artistId, sub.tokenAddress, sub.amount);
            return true;
        } else {
            // 결제 실패 시 구독 취소 처리
            sub.active = false;
            _removeFromArtistSubscriptionList(subscriberId, artistId);
            _removeFromArray(artistSubscribers[artistId], subscriberId);
            _removeFromArray(userSubscribedArtists[subscriberId], artistId);
            emit ArtistSubscriptionCancelled(subscriberId, artistId);
            return false;
        }
    }

    // 외부 호출용 함수 (이전 코드와의 호환성 유지)
    function processRegularPayment(uint256 userId) external returns (bool) {
        return _processRegularPayment(userId);
    }

    // 외부 호출용 함수 (이전 코드와의 호환성 유지)
    function processArtistPayment(uint256 subscriberId, uint256 artistId) external returns (bool) {
        return _processArtistPayment(subscriberId, artistId);
    }

    // Chainlink Keeper 호환 인터페이스 구현
    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory performData) {
        // 1. 정기 구독 확인
        uint256[] memory regularIds = new uint256[](MAX_UPKEEP_SUBSCRIPTIONS);
        uint256 regularCount = 0;

        for (uint256 i = 0; i < activeRegularSubscribers.length && regularCount < MAX_UPKEEP_SUBSCRIPTIONS; i++) {
            uint256 userId = activeRegularSubscribers[i];
            RegularSubscription storage sub = regularSubscriptions[userId];

            if (sub.active && block.timestamp >= sub.lastPaymentTime + sub.interval) {
                regularIds[regularCount] = userId;
                regularCount++;
            }
        }

        // 2. 아티스트 구독 확인
        uint256[] memory subscriberIds = new uint256[](MAX_UPKEEP_SUBSCRIPTIONS);
        uint256[] memory artistIds = new uint256[](MAX_UPKEEP_SUBSCRIPTIONS);
        uint256 artistSubCount = 0;

        for (uint256 i = 0; i < activeArtistSubscriptions.length && artistSubCount < MAX_UPKEEP_SUBSCRIPTIONS; i++) {
            uint256 subId = activeArtistSubscriptions[i].subscriberId;
            uint256 artId = activeArtistSubscriptions[i].artistId;
            ArtistSubscription storage sub = artistSubscriptions[subId][artId];

            if (sub.active && block.timestamp >= sub.lastPaymentTime + sub.interval) {
                subscriberIds[artistSubCount] = subId;
                artistIds[artistSubCount] = artId;
                artistSubCount++;
            }
        }

        // 처리할 구독이 없으면 false 반환
        upkeepNeeded = (regularCount > 0 || artistSubCount > 0);

        // 처리할 ID 목록 인코딩
        performData = abi.encode(regularIds, regularCount, subscriberIds, artistIds, artistSubCount);

        return (upkeepNeeded, performData);
    }

    // Chainlink Keeper 호환 인터페이스 구현
    function performUpkeep(bytes calldata performData) external override {
        // 디코딩
        (
            uint256[] memory regularIds,
            uint256 regularCount,
            uint256[] memory subscriberIds,
            uint256[] memory artistIds,
            uint256 artistSubCount
        ) = abi.decode(performData, (uint256[], uint256, uint256[], uint256[], uint256));

        // 1. 정기 구독 처리
        for (uint256 i = 0; i < regularCount; i++) {
            _processRegularPayment(regularIds[i]);
        }

        // 2. 아티스트 구독 처리
        for (uint256 i = 0; i < artistSubCount; i++) {
            _processArtistPayment(subscriberIds[i], artistIds[i]);
        }
    }

    // 정산 함수: 오프체인에서 전달받은 아티스트 별 스트리밍 횟수 데이터를 사용하여
    // 컨트랙트에 보관 중인 해당 구독자의 결제 토큰을 분배합니다.
    function settlePaymentsRegularByArtist(
        uint256 subscriberId,
        uint256 cycleId, // 정산 주기 ID
        uint256 totalAmount, // 정산할 총 금액
        uint256[] calldata artistIds,
        uint256[] calldata streamingCounts // 각 아티스트의 스트리밍 횟수
    ) external onlyOwner returns (bool) {
        require(artistIds.length == streamingCounts.length, "Mismatched array lengths");

        // 플랫폼 몫: 전체 금액의 10%
        uint256 platformShare = (totalAmount * 10) / 100;
        // 아티스트에게 분배할 총액은 전체 금액에서 플랫폼 몫을 뺀 금액
        uint256 distributable = totalAmount - platformShare;
        uint256 totalStreaming = _getTotalStreaming(streamingCounts);
        require(totalStreaming > 0, "No streaming counts provided");

        for (uint256 i = 0; i < artistIds.length; i++) {
            address artistAddr = artistAddresses[artistIds[i]];
            require(artistAddr != address(0), "Artist not registered");
            // 각 아티스트에게 지급할 금액 = distributable * (해당 아티스트 스트리밍 횟수) / (전체 스트리밍 횟수)
            uint256 payout = (distributable * streamingCounts[i]) / totalStreaming;
            IERC20(defaultTokenAddress).safeTransfer(artistAddr, payout);
            _emitSettlementExecutedRegular(subscriberId, cycleId, artistIds[i], payout, streamingCounts[i]);
        }

        // 플랫폼 몫을 소유자(플랫폼)에게 송금
        IERC20(defaultTokenAddress).safeTransfer(owner(), platformShare);
        return true;
    }

    // 정산 함수: 아티스트 구독에 대한 정산
    // 플랫폼이 10% 아티스트는 90%를 가져감
    function settlePaymentsArtist(
        uint256 subscriberId,
        uint256 artistId,
        uint256 cycleId, // 정산 주기 ID
        uint256 totalAmount // 정산할 총 금액
    ) external onlyOwner returns (bool) {
        require(artistAddresses[artistId] != address(0), "Artist not registered");

        // 10%는 플랫폼(소유자), 90%는 아티스트로 분배
        uint256 ownerShare = (totalAmount * 10) / 100;
        uint256 artistShare = totalAmount - ownerShare;

        // 아티스트 몫을 아티스트 주소에 송금
        IERC20(defaultTokenAddress).safeTransfer(artistAddresses[artistId], artistShare);
        // 정산 이벤트 발생
        _emitSettlementExecutedArtist(subscriberId, artistId, cycleId, artistShare);

        // 플랫폼 몫을 소유자(플랫폼)에게 송금
        IERC20(defaultTokenAddress).safeTransfer(owner(), ownerShare);

        return true;
    }

    // 헬퍼 함수: 전달받은 스트리밍 횟수 배열의 총합 계산
    function _getTotalStreaming(uint256[] calldata streamingCounts) internal pure returns (uint256 sum) {
        for (uint256 i = 0; i < streamingCounts.length; i++) {
            sum += streamingCounts[i];
        }
    }

    // 헬퍼 함수: 배열에서 특정 값을 제거
    function _removeFromArray(uint256[] storage array, uint256 value) internal {
        uint256 length = array.length;
        for (uint256 i = 0; i < length; i++) {
            if (array[i] == value) {
                array[i] = array[length - 1];
                array.pop();
                break;
            }
        }
    }

    // 헬퍼 함수: 활성 정기 구독자 목록에 추가
    function _addToRegularSubscriberList(uint256 userId) internal {
        if (regularSubscriberIndex[userId] == 0) {
            activeRegularSubscribers.push(userId);
            regularSubscriberIndex[userId] = activeRegularSubscribers.length;
        }
    }

    // 헬퍼 함수: 활성 정기 구독자 목록에서 제거
    function _removeFromRegularSubscriberList(uint256 userId) internal {
        uint256 index = regularSubscriberIndex[userId];
        if (index > 0) {
            // 인덱스는 1부터 시작하므로 1을 빼줌
            index--;

            // 마지막 요소가 아니면 스왑
            if (index < activeRegularSubscribers.length - 1) {
                uint256 lastUserId = activeRegularSubscribers[activeRegularSubscribers.length - 1];
                activeRegularSubscribers[index] = lastUserId;
                regularSubscriberIndex[lastUserId] = index + 1;
            }

            // 마지막 요소 제거
            activeRegularSubscribers.pop();
            regularSubscriberIndex[userId] = 0;
        }
    }

    // 헬퍼 함수: 활성 아티스트 구독 목록에 추가
    function _addToArtistSubscriptionList(uint256 subscriberId, uint256 artistId) internal {
        if (artistSubscriptionIndex[subscriberId][artistId] == 0) {
            activeArtistSubscriptions.push(ArtistSubscriptionPair({
                subscriberId: subscriberId,
                artistId: artistId
            }));
            artistSubscriptionIndex[subscriberId][artistId] = activeArtistSubscriptions.length;
        }
    }

    // 헬퍼 함수: 활성 아티스트 구독 목록에서 제거
    function _removeFromArtistSubscriptionList(uint256 subscriberId, uint256 artistId) internal {
        uint256 index = artistSubscriptionIndex[subscriberId][artistId];
        if (index > 0) {
            // 인덱스는 1부터 시작하므로 1을 빼줌
            index--;

            // 마지막 요소가 아니면 스왑
            if (index < activeArtistSubscriptions.length - 1) {
                ArtistSubscriptionPair storage lastItem = activeArtistSubscriptions[activeArtistSubscriptions.length - 1];
                activeArtistSubscriptions[index] = lastItem;
                artistSubscriptionIndex[lastItem.subscriberId][lastItem.artistId] = index + 1;
            }

            // 마지막 요소 제거
            activeArtistSubscriptions.pop();
            artistSubscriptionIndex[subscriberId][artistId] = 0;
        }
    }

    // 헬퍼 함수: SettlementExecutedRegular 이벤트를 emit (Stack too deep 완화)
    function _emitSettlementExecutedRegular(
        uint256 subscriberId,
        uint256 artistId,
        uint256 cycleId,
        uint256 payout,
        uint256 streamingCount
    ) internal {
        emit SettlementExecutedRegular(subscriberId, artistId, cycleId, payout, streamingCount);
    }

    // 헬퍼 함수: SettlementExecutedArtist 이벤트를 emit (Stack too deep 완화)
    function _emitSettlementExecutedArtist(
        uint256 subscriberId,
        uint256 artistId,
        uint256 cycleId,
        uint256 payout
    ) internal {
        emit SettlementExecutedArtist(subscriberId, artistId, cycleId, payout);
    }

    // 정기구독 정보 조회
    function getRegularSubscription(uint256 userId) external view returns (
        uint256 startDate,
        uint256 amount,
        uint256 lastPaymentTime,
        uint256 nextPaymentTime,
        bool active,
        address tokenAddress
    ) {
        RegularSubscription memory sub = regularSubscriptions[userId];
        return (sub.startDate, sub.amount, sub.lastPaymentTime, sub.lastPaymentTime + sub.interval, sub.active, sub.tokenAddress);
    }

    // 아티스트 구독 정보 조회
    function getArtistSubscription(uint256 subscriberId, uint256 artistId) external view returns (
        uint256 startDate,
        uint256 amount,
        uint256 lastPaymentTime,
        uint256 nextPaymentTime,
        bool active,
        address tokenAddress
    ) {
        ArtistSubscription memory sub = artistSubscriptions[subscriberId][artistId];
        return (sub.startDate, sub.amount, sub.lastPaymentTime, sub.lastPaymentTime + sub.interval, sub.active, sub.tokenAddress);
    }

    // 특정 아티스트의 구독자 수 조회
    function getArtistSubscriberCount(uint256 artistId) external view returns (uint256) {
        return artistSubscribers[artistId].length;
    }

    // 특정 아티스트의 구독자 ID 목록 조회
    function getArtistSubscribers(uint256 artistId) external view returns (uint256[] memory) {
        return artistSubscribers[artistId];
    }

    // 특정 사용자가 구독한 아티스트 수 조회
    function getUserSubscribedArtistCount(uint256 userId) external view returns (uint256) {
        return userSubscribedArtists[userId].length;
    }

    // 특정 사용자가 구독한 아티스트 ID 목록 조회
    function getUserSubscribedArtists(uint256 userId) external view returns (uint256[] memory) {
        return userSubscribedArtists[userId];
    }

    // 사용자 주소로 사용자 ID 조회
    function getUserIdByAddress(address userAddress) external view returns (uint256) {
        return addressToUserId[userAddress];
    }

    // 아티스트 ID로 아티스트 주소 조회
    function getArtistAddressById(uint256 artistId) external view returns (address) {
        return artistAddresses[artistId];
    }

    // 현재 활성 정기구독 사용자 목록 조회
    function getActiveRegularSubscribers() external view returns (uint256[] memory) {
        return activeRegularSubscribers;
    }

    // 현재 활성 아티스트 구독 목록 조회
    function getActiveArtistSubscriptions() external view returns (
        uint256[] memory subscriberIds,
        uint256[] memory artistIds
    ) {
        subscriberIds = new uint256[](activeArtistSubscriptions.length);
        artistIds = new uint256[](activeArtistSubscriptions.length);

        for (uint256 i = 0; i < activeArtistSubscriptions.length; i++) {
            subscriberIds[i] = activeArtistSubscriptions[i].subscriberId;
            artistIds[i] = activeArtistSubscriptions[i].artistId;
        }

        return (subscriberIds, artistIds);
    }

    // ERC-20 토큰을 인출하는 함수
    function withdrawToken(address tokenAddress) public onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");

        // 안전한 방식으로 오너에게 송금
        token.safeTransfer(owner(), balance);
    }
}