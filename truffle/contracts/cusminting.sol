// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "node_modules/@openzeppelin/contracts/access/Ownable.sol";

import "node_modules/@openzeppelin/contracts/utils/Strings.sol";


contract cusminting is ERC721Enumerable, Ownable{

    uint constant public MAX_TOKEN_COUNT = 1000;
    // NFT 발행량을 제한하고 싶은 경우
    // Solidity 상수 선언 constant

    uint public mint_price = 1 ether;
    // 연산으로 양을 표현하게 될 경우 가스비 소모
    // Solidity 에서는 1 ether 라고 표현하면 알아서 10**18 로 표현

    string public metadataURI;

    constructor(string memory _name, string memory _symbol, string memory _metadataURI) ERC721(_name, _symbol) {
        metadataURI = _metadataURI;
    }

    // tokenId 값에 따라 랜덤한 Rank, Type을 부여하기 위한 구조체
    struct TokenData {
        uint Rank;
        uint Type;
    }

    mapping(uint => TokenData) public TokenDatas;
    // tokenId => TokenData

    uint[4][4] public tokenCount;
    // 사용자에게 NFT 발행 상황을 보여주기 위한 용도의 상태변수

    function mintToken() public payable {
        // mintToken() 을 실행할 때 이더를 지급하게끔 함. CA에게 이더를 지급해서 NFT를 사는 개념.

        require(msg.value >= mint_price);
        require(MAX_TOKEN_COUNT > ERC721Enumerable.totalSupply());

        uint tokenId = ERC721Enumerable.totalSupply() + 1;
        // 총 발행량 + 1 로 tokenId 값 형성

        // _tokenId 에 따라 metadata의 Rank와 Type을 랜덤하게 생성하여 TokenDatas 상태변수에 저장
        TokenData memory random = getRandomTokenData(msg.sender, tokenId);  // 함수 실행 종료시 메모리 데이터 날림
        TokenDatas[tokenId] = random;

        tokenCount[TokenDatas[tokenId].Rank - 1][TokenDatas[tokenId].Type - 1] += 1;

        // CA -> 컨트랙트 배포자 계정으로 지급받은 이더 전송
        payable(Ownable.owner()).transfer(msg.value);

        // mintToken() 을 호출한 계정에게 NFT 발행
        _mint(msg.sender, tokenId);

    }

    function tokenURI(uint _tokenId) public override view returns (string memory) {

        // if metadataURI : http://localhost:3000/metadata
        // return : http://localhost:3000/metadata/1/4.json

        // uint -> string 형태로 바로 형변환 불가능
        // uint -> bytes -> string 으로 형변환
        // utils 디렉토리 안에 존재하는 Strings.sol 파일 활용
        string memory Rank = Strings.toString(TokenDatas[_tokenId].Rank);
        string memory Type = Strings.toString(TokenDatas[_tokenId].Type);

        // abi.encodePacked("http://localhost:3000/metadata", "/", Rank, "/", Type, ".json")
        return string(abi.encodePacked(metadataURI, "/", Rank, "/", Type, ".json"));

    }

    // TokenData를 랜덤하게 만들어주는 함수
    function getRandomTokenData(address _owner, uint _tokenId) private pure returns (TokenData memory) {
        // Solidity에는 random 함수 부재
        // 특정한 값 해싱 후 나머지 연산으로 랜덤값 뽑아오는 방식으로 구현

        // abi.encodePacked(_owner, _tokenId);  // 타입과 상관없이 합쳐주는 메소드
        uint randomNum = uint(keccak256(abi.encodePacked(_owner, _tokenId)))%100;   // Solidity에서 주로 사용되는 랜덤값 구하는 방법
        // keccak256 -> 32 byte
        // 주의 : keccak256() 에 같은 string 값을 전달하면 X

        // 상태변수를 사용한 게 아니라 메모리 상에 잠시 데이터를 저장한 것.
        TokenData memory data;
        // 메모리 상에 data 라는 객체를 만든 것

        if (randomNum < 5) {
            if (randomNum == 1) {
                data.Rank = 4;
                data.Type = 1;
            } else if (randomNum == 2) {
                data.Rank = 4;
                data.Type = 2;
            } else if (randomNum == 3) {
                data.Rank = 4;
                data.Type = 3;
            } else {
                data.Rank = 4;
                data.Type = 4;
            }
        } else if (randomNum < 13) {
            if (randomNum < 7) {
                data.Rank = 3;
                data.Type = 1;
            } else if (randomNum < 9) {
                data.Rank = 3;
                data.Type = 2;
            } else if (randomNum < 11) {
                data.Rank = 3;
                data.Type = 3;
            } else {
                data.Rank = 3;
                data.Type = 4;
            }
        } else if (randomNum < 37) {
            if (randomNum < 19) {
                data.Rank = 2;
                data.Type = 1;
            } else if (randomNum < 25) {
                data.Rank = 2;
                data.Type = 2;
            } else if (randomNum < 31) {
                data.Rank = 2;
                data.Type = 3;
            } else {
                data.Rank = 2;
                data.Type = 4;
            }
        } else {
            if (randomNum < 52) {
                data.Rank = 1;
                data.Type = 1;
            } else if (randomNum < 68) {
                data.Rank = 1;
                data.Type = 2;
            } else if (randomNum < 84) {
                data.Rank = 1;
                data.Type = 3;
            } else {
                data.Rank = 1;
                data.Type = 4;
            }
        }

        return data;
    }
    
    // metadataURI를 수정할 수 있는 함수
    // onlyOwner : owner(컨트랙트 배포자)만 실행시킬 수 있도록 하는 접근제한자
    function setMetadataURI(string memory _uri) public onlyOwner {
        metadataURI = _uri;
    }

    // TokenData의 Rank 조회
    function getTokenRank(uint _tokenId) public view returns (uint) {
        return TokenDatas[_tokenId].Rank;
    }

    // TokenData의 Type 조회
    function getTokenType(uint _tokenId) public view returns (uint) {
        return TokenDatas[_tokenId].Type;
    }

    // 배열 전체를 return 하기 위한 view 함수
    // getter 함수로 배열 전체를 조회하는 것은 불가능.
    // getter 함수는 요소 하나만 return 하기 때문에 배열 전체를 return하는 view 함수를 따로 만들어줌.
    function getTokenCount() public view returns (uint[4][4] memory) {
        return tokenCount;
    }
    
}