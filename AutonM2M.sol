// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Interface for Auton Token (must support transferFrom and burn)
interface IAutonToken {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function burn(uint256 amount) external;  // Burn function must exist in AutonToken
}

contract AutonM2M {
    IAutonToken public autonToken;
    address public architect;

    // Fixed rates (immutable for Atal Niyam principles)
    uint256 public constant energyRate = 1;          // 1 energy unit costs 1 $AUTON (low for high-volume M2M)
    uint256 public constant satelliteLinkFee = 50;   // Fee to register one Space Node

    // Burn 20% of every fee paid (deflationary mechanism)
    uint256 public constant burnPercentage = 20;

    // Events for full transparency
    event EnergyTraded(address indexed machine, address indexed station, uint256 units, uint256 totalCost, uint256 burned);
    event SpaceNodeActivated(address indexed satellite, uint256 totalFee, uint256 burned);

    constructor(address _autonTokenAddress) {
        architect = msg.sender;
        autonToken = IAutonToken(_autonTokenAddress);
    }

    /**
     * @dev Buy energy units from a solar station. 20% of payment is burned.
     */
    function buyEnergy(address solarStation, uint256 units) public returns (bool) {
        uint256 totalCost = units * energyRate;
        uint256 burnAmount = (totalCost * burnPercentage) / 100;
        uint256 netPayment = totalCost - burnAmount;

        // Transfer full amount to this contract first
        require(autonToken.transferFrom(msg.sender, address(this), totalCost), "Insufficient $AUTON or approval");

        // Burn portion
        autonToken.burn(burnAmount);

        // Send remaining to solar station
        autonToken.transfer(solarStation, netPayment);

        emit EnergyTraded(msg.sender, solarStation, units, totalCost, burnAmount);
        return true;
    }

    /**
     * @dev Register a satellite as a Space Node. 20% of fee is burned.
     */
    function registerSpaceNode(address satelliteAddr) public returns (bool) {
        uint256 totalFee = satelliteLinkFee;
        uint256 burnAmount = (totalFee * burnPercentage) / 100;
        uint256 netFee = totalFee - burnAmount;

        // Transfer full fee to this contract
        require(autonToken.transferFrom(msg.sender, address(this), totalFee), "Insufficient $AUTON for registration");

        // Burn portion
        autonToken.burn(burnAmount);

        // Send remaining to architect (or change to treasury later)
        autonToken.transfer(architect, netFee);

        emit SpaceNodeActivated(satelliteAddr, totalFee, burnAmount);
        return true;
    }
}
