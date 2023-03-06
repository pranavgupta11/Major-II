// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

contract product {

    uint256 sellerCount;
    uint256 productCount;

    struct seller{
        uint256 sellerId; // automated
        string sellerName;
        string sellerBrand;
        string sellerCode; // Password (GST(5)+Phone(4))
        uint256 sellerNum;
        address sellerManager;
        address sellerAddress;
    }
    mapping(uint=>seller) public sellers; // 0 -> sellers details

    struct productItem{
        uint256 productId;//Automated
        string productSN;
        string productName;
        string productBrand;
        uint256 productPrice;
        string productStatus;
    }

    mapping(uint256=>productItem) public productItems; //product id  -> details
    mapping(string=>uint256) public productMap; //productSno -> count(id)
    mapping(string=>string) public productsManufactured; //product Sn -> mfr
    mapping(string=>string) public productsForSale; //productSn -> Seller Code
    mapping(string=>string) public productsSold; //productSn-> Consumer Code
    mapping(string=>string[]) public productsWithSeller; //sellerCode -> ProductSno
    mapping(string=>string[]) public productsWithConsumer; //ConsumerCode -> ProductSn
    mapping(string=>string[]) public sellersWithManufacturer; //Mfr id -> seller code

    // String Custom Comparator
    function memcmp(bytes memory a, bytes memory b) internal pure returns(bool){
        return (a.length == b.length) && (keccak256(a) == keccak256(b));
    }
    function strcmp(string memory a, string memory b) internal pure returns(bool){
        return memcmp(bytes(a), bytes(b));
    }
    //SELLER SECTION

    function addSeller(string memory _manufacturerId, string memory _sellerName, string memory _sellerBrand, string memory _sellerCode,
    uint256 _sellerNum, address _sellerManager, address _sellerAddress) public{
        sellers[sellerCount] = seller(sellerCount, _sellerName, _sellerBrand, _sellerCode,
        _sellerNum, _sellerManager, _sellerAddress);
        sellerCount++;
        sellersWithManufacturer[_manufacturerId].push(_sellerCode);
    }


    function viewSellers () public view returns(uint256[] memory, string[] memory, string[] memory, string[] memory, uint256[] memory, address[] memory, address[] memory) {
        uint256[] memory ids = new uint256[](sellerCount);
        string[] memory snames = new string[](sellerCount);
        string[] memory sbrands = new string[](sellerCount);
        string[] memory scodes = new string[](sellerCount);
        uint256[] memory snums = new uint256[](sellerCount);
        address[] memory smanagers = new address[](sellerCount);
        address[] memory saddress = new address[](sellerCount);
        
        for(uint i=0; i<sellerCount; i++){
            ids[i] = sellers[i].sellerId;
            snames[i] = sellers[i].sellerName;
            sbrands[i] = sellers[i].sellerBrand;
            scodes[i] = sellers[i].sellerCode;
            snums[i] = sellers[i].sellerNum;
            smanagers[i] = sellers[i].sellerManager;
            saddress[i] = sellers[i].sellerAddress;
        }
        return(ids, snames, sbrands, scodes, snums, smanagers, saddress);
    }

    //PRODUCT SECTION

    function addProduct(string memory _manufactuerID, string memory _productName, string memory _productSN, string memory _productBrand,
    uint256 _productPrice) public{
        productItems[productCount] = productItem(productCount, _productSN, _productName, _productBrand,
        _productPrice, "Available");
        productMap[_productSN] = productCount;
        productCount++;
        productsManufactured[_productSN] = _manufactuerID;
    }


    function viewProductItems () public view returns(uint256[] memory, string[] memory, string[] memory, string[] memory, uint256[] memory, string[] memory) {
        uint256[] memory pids = new uint256[](productCount);
        string[] memory pSNs = new string[](productCount);
        string[] memory pnames = new string[](productCount);
        string[] memory pbrands = new string[](productCount);
        uint256[] memory pprices = new uint256[](productCount);
        string[] memory pstatus = new string[](productCount);
        
        for(uint i=0; i<productCount; i++){
            pids[i] = productItems[i].productId;
            pSNs[i] = productItems[i].productSN;
            pnames[i] = productItems[i].productName;
            pbrands[i] = productItems[i].productBrand;
            pprices[i] = productItems[i].productPrice;
            pstatus[i] = productItems[i].productStatus;
        }
        return(pids, pSNs, pnames, pbrands, pprices, pstatus);
    }

    //SELL Product

    function manufacturerSellProduct(string memory _productSN, string memory _sellerCode) public{
        productsWithSeller[_sellerCode].push(_productSN);
        productsForSale[_productSN] = _sellerCode;

    }

    function sellerSellProduct(string memory _productSN, string memory _consumerCode) public{   
        string memory pStatus;
        uint256 i;
        uint256 j=0;

        if(productCount>0) {
            for(i=0;i<productCount;i++) {
                if(strcmp(productItems[i].productSN, _productSN)) {
                    j=i;
                }
            }
        }

        pStatus = productItems[j].productStatus;
        if(strcmp(pStatus,"Available")) {
            productItems[j].productStatus = "NA";
            productsWithConsumer[_consumerCode].push(_productSN);
            productsSold[_productSN] = _consumerCode;
        }


    }


    function queryProductsList(string memory _sellerCode) public view returns(uint256[] memory, string[] memory, string[] memory, string[] memory, uint256[] memory, string[] memory){
        string[] memory productSNs = productsWithSeller[_sellerCode];
        uint256 k=0;

        uint256[] memory pids = new uint256[](productCount);
        string[] memory pSNs = new string[](productCount);
        string[] memory pnames = new string[](productCount);
        string[] memory pbrands = new string[](productCount);
        uint256[] memory pprices = new uint256[](productCount);
        string[] memory pstatus = new string[](productCount);

        
        for(uint i=0; i<productCount; i++){
            for(uint j=0; j<productSNs.length; j++){
                if(strcmp(productItems[i].productSN,productSNs[j])){
                    pids[k] = productItems[i].productId;
                    pSNs[k] = productItems[i].productSN;
                    pnames[k] = productItems[i].productName;
                    pbrands[k] = productItems[i].productBrand;
                    pprices[k] = productItems[i].productPrice;
                    pstatus[k] = productItems[i].productStatus;
                    k++;
                }
            }
        }
        return(pids, pSNs, pnames, pbrands, pprices, pstatus);
    }

    function querySellersList (string memory _manufacturerCode) public view returns(uint256[] memory, string[] memory, string[] memory, string[] memory, uint256[] memory, address[] memory, address[] memory) {
        string[] memory sellerCodes = sellersWithManufacturer[_manufacturerCode];
        uint256 k=0;
        uint256[] memory ids = new uint256[](sellerCount);
        string[] memory snames = new string[](sellerCount);
        string[] memory sbrands = new string[](sellerCount);
        string[] memory scodes = new string[](sellerCount);
        uint256[] memory snums = new uint256[](sellerCount);
        address[] memory smanagers = new address[](sellerCount);
        address[] memory saddress = new address[](sellerCount);
        
        for(uint i=0; i<sellerCount; i++){
            for(uint j=0; j<sellerCodes.length; j++){
                if(strcmp(sellers[i].sellerCode, sellerCodes[j])){
                    ids[k] = sellers[i].sellerId;
                    snames[k] = sellers[i].sellerName;
                    sbrands[k] = sellers[i].sellerBrand;
                    scodes[k] = sellers[i].sellerCode;
                    snums[k] = sellers[i].sellerNum;
                    smanagers[k] = sellers[i].sellerManager;
                    saddress[k] = sellers[i].sellerAddress;
                    k++;
                    break;
               }
            }
        }

        return(ids, snames, sbrands, scodes, snums, smanagers, saddress);
    }

    function getPurchaseHistory(string memory _consumerCode) public view returns (string[] memory, string[] memory, string[] memory){
        string[] memory productSNs = productsWithConsumer[_consumerCode];
        string[] memory sellerCodes = new string[](productSNs.length);
        string[] memory manufacturerCodes = new string[](productSNs.length);
        for(uint i=0; i<productSNs.length; i++){
            sellerCodes[i] = productsForSale[productSNs[i]];
            manufacturerCodes[i] = productsManufactured[productSNs[i]];
        }
        return (productSNs, sellerCodes, manufacturerCodes);
    }

    //Verify

    function verifyProduct(string memory _productSN, string memory _consumerCode) public view returns(bool){
        if(strcmp(productsSold[_productSN], _consumerCode)){
            return true;
        }
        else{
            return false;
        }
    }
}