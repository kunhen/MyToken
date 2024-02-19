// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interface/IMyToken.sol";
import "./utilContracts/MyAuth.sol";

import "./interface/IMyController.sol";

import "./utilContracts/MyUtility.sol";

contract MyToken is IMyToken, MyAuth {

    bytes private myImmutableData;
    string private myProjectName;
    uint256 public immutable myId;

    address private immutable myControllerContractAddress = msg.sender;

    constructor(bytes memory projectImmutableData, string memory name, uint256 tokenId, address projectOwner) MyAuth(projectOwner)
    {
        myImmutableData = projectImmutableData;
        myProjectName = name;
        myId = tokenId;
    }

    //private
    function withdrawFunds(uint256 amount) private {
        require(amount > 0, "Amount must be greater than 0. Error:5");
        require(address(this).balance >= amount, "Insufficient funds in the contract. Error:6");

        payable(msg.sender).transfer(amount);
    }

    //public 
    function getProjectName() public view returns(string memory){
        return myProjectName;
    }

    //external 
    function getImmutableData() external view returns(bytes memory){
        return myImmutableData;
    }

    function requestFunds(uint256 amount, string memory reason) external onlyProjectAuth {
        MoneyRequest memory moneyRequestObject = MoneyRequest({
            requestId: 0,
            money: amount,
            requestReason: reason,
            requestBy: msg.sender,
            status: ProjectMoneyEventType.SendMoneyRequest,
            rejectReason: "",
            rejectedBy: address(0),
            tokenId: myId,
            approvedBy: address(0)
        });

        uint256 requestId = IMyController(myControllerContractAddress).projectMoneyRequest(moneyRequestObject);

        emit MoneyReqeustEvent(requestId, amount, reason);
        emit ProjectEvent(ProjectMoneyEventType.SendMoneyRequest, moneyRequestObject.requestBy, moneyRequestObject.money, moneyRequestObject.requestReason);
    }

    function withdrawFunds(uint256 amount, string memory reason) external onlyProjectAuth {

        withdrawFunds(amount);
        emit ProjectEvent(ProjectMoneyEventType.MoneyWithdrawal, msg.sender, amount, reason);
    }

    receive() external payable {}
}
