// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// TODO: import "@openzeppelin/contracts/access/AccessControl.sol";
// TODO: https://docs.openzeppelin.com/contracts/3.x/access-control
// TODO: https://docs.openzeppelin.com/contracts/3.x/upgradeable

contract NFT is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable, ReentrancyGuard {
    // https://gist.github.com/Chmarusso/5b2012b7dc9afec33ec19d1583046f4a Chmarusso/FeeCollector.sol
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address marketAddress;
    address scoreAddress;
    // address payable ownerOfContract;
    // using Strings for uint256;
    // mapping (uint256 => string) private _tokenURIs;
    // mapping ( address => uint256 ) public balances;

    constructor(address marketplaceAddress, address scoreTokenAddress) ERC721("CC6", "CC6") {
        marketAddress = marketplaceAddress;
        scoreAddress = scoreTokenAddress;
        // ownerOfContract = payable(msg.sender);
    }

    // https://forum.openzeppelin.com/t/how-do-inherit-from-erc721-erc721enumerable-and-erc721uristorage-in-v4-of-openzeppelin-contracts/6656/4
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    // https://ethereum.stackexchange.com/questions/31457/substring-in-solidity/31470
    function _substring(string memory str, uint startIndex, uint endIndex) private pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
        for(uint i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = strBytes[i];
        }
        return string(result);
    }

    // TODO: tokenURI should starts with ipfs:// or ipns:// in the future. P2
    // TODO: should run by author of tokenURI, P2. ipfs://bafyxxx/?author=0xaaa
    // https://docs.ipfs.io/how-to/mint-nfts-with-ipfs/#a-short-introduction-to-nfts
    function createToken(string memory uri) public returns (uint256) {
        // https://ethereum.stackexchange.com/questions/4559/operator-not-compatible-with-type-string-storage-ref-and-literal-string
        string memory firststr = _substring(uri, 0, 12);
        require(keccak256(bytes(firststr)) == keccak256("https://bafy"), "firststr not same");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId); // msg.sender is recipient
        _setTokenURI(newItemId, uri);
        setApprovalForAll(marketAddress, true);

        // uint256 giftScore = 1 ether; // TODO
        // IERC20 scoreToken = ERC20(scoreAddress);
        // uint256 erc20balance = scoreToken.balanceOf(address(this));
        // require(giftScore < erc20balance, "balance too low");
        // ERC20(scoreAddress).transfer(msg.sender, giftScore); // for proof of creation
        
        return newItemId;
    }

    function mintAsDonorFromAuthor(string memory uri, address _author) public payable nonReentrant returns (uint256) {
        // 3. 捐赠者购买（创作者的）NFT作为捐赠，
        // 花费0.1Matic（1份）（其中0.09Matic给创作者，平台收取0.01Matic作为手续费，手续费的66.666%会返还给早期捐赠者，剩下的3.333%用于创作者dao）
        // gas费需要0.1分钱？
        // 捐赠者获取1个ScoreToken（捐赠挖矿），创作者获取4个ScoreToken（创作挖矿）  【也支持一次捐赠1Matic（10份）】
        
        // cracker may set _author to themselves got got ScoreToken?
        // require(_amount > 0, "Gift need > 0");
        string memory firststr = _substring(uri, 0, 12);
        require(keccak256(bytes(firststr)) == keccak256("https://bafy"), "need https://bafy*");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId); // msg.sender is recipient
        _setTokenURI(newItemId, uri);

        // msg.sender.transferFrom(msg.sender, _author, _amount * 0.09 ether);
        // msg.sender.transferFrom(msg.sender, address(this), _amount * 0.01 ether); // or owner()
        // payable(msg.sender).transfer(1 ether); // for proof of donation
        // require(msg.value == _amount);
        // require(ownerOfContract == owner());
        // payable(ownerOfContract).transfer(1 ether); // for proof of donation
        // payable(owner()).transfer(1 ether); // for proof of donation
        uint256 author_amount = SafeMath.mul(SafeMath.div(msg.value, 10), 9);
        payable(_author).transfer(author_amount);
        payable(owner()).transfer(msg.value-author_amount);

        IERC20 scoreToken = ERC20(scoreAddress);
        require(msg.value < scoreToken.balanceOf(address(this)), "balance too low");
        ERC20(scoreAddress).transfer(_author, msg.value); // for proof of creation
        ERC20(scoreAddress).transfer(msg.sender, msg.value); // for proof of donation

        return newItemId;
    }

    // function _baseURI() internal pure override returns (string memory) {
    //     return "https://foo.com/token/";
    // }

    // function burn2(uint256 tokenId) public {
    //     require(msg.sender == ownerOf(tokenId), "Only owner can burn nft");
    //     _burn(tokenId);
    // }


    function exists(uint256 tokenId) public view returns(bool){
        // require(msg.sender == ownerOf(tokenId), "Only owner can burn nft");
        return _exists(tokenId);
    }

    // https://forum.openzeppelin.com/t/expose-tokensofowner-method-on-erc721enumerable/888/8
    // Pagination of owner tokens
    function tokensOfOwner(address _owner, uint8 _page, uint8 _rows) public view returns(uint256[] memory) {
        require(_page > 0, "_page should be greater than 0");
        require(_rows > 0, "_rows should be greater than 0");

        uint256 _tokenCount = balanceOf(_owner);
        uint256 _offset = (_page - 1) * _rows;
        uint256 _range = _offset > _tokenCount ? 0 : Math.min(_tokenCount - _offset, _rows);

        uint256[] memory _tokens = new uint256[](_range);
        for (uint256 i = 0; i < _range; i++) {
            _tokens[i] = tokenOfOwnerByIndex(_owner, _offset + i);
        }
        return _tokens;
    }

    // https://forum.openzeppelin.com/t/interfaces-with-parameters-in-other-contracts/22752
    // https://stackoverflow.com/questions/70584388/sending-erc20-tokens-using-the-transfer-function
    // function withdraw(uint amount, address payable destAddr) public {
    //     require(msg.sender == owner, "Only owner can withdraw funds");
    //     require(amount <= balance, "Insufficient funds");
    //     destAddr.transfer(amount);
    //     balance -= amount;
    //     emit TransferSent(msg.sender, destAddr, amount);
    // }

    // https://www.reddit.com/r/solidity/comments/majsgl/proper_way_to_withdraw_erc20_tokens_from_a_smart/
    // function withdrawToken1(IERC20 token) public onlyOwner {
    //     uint256 memory funds = token.balanceOf(address(this));
    //     require(funds != 0);
    //     token.transfer(owner(), funds);
    // }

    // https://stackoverflow.com/questions/68545930/how-to-withdraw-all-tokens-from-the-my-contract-in-solidity
    // https://ethereum.stackexchange.com/questions/19380/external-vs-public-best-practices
    // renounceOwnership relinquish this administrative privilege, a common pattern after an initial stage with centralized administration is over.
    function withdrawToken(address _tokenContract, uint256 _amount) external onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContract);
        // transfer the token from address of this contract
        // to address of the user (executing the withdrawToken() function)
        // tokenContract.transfer(msg.sender, _amount);
        tokenContract.transfer(owner(), _amount);
        // https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/
        // This forwards all available gas. Be sure to check the return value!
        // (bool success, ) = owner().call.value(_amount)("");
        // require(success, "withdraw failed.");
    }

}
