// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAutonToken {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract AutonM2M {
    IAutonToken public autonToken;
    address public architect;

    // Rules for Energy and Space
    uint256 public energyRate = 5; // 1 Unit = 5 $AUTON
    uint256 public satelliteLinkFee = 100; // Registration for Space Nodes

    event EnergyTraded(address indexed machine, address indexed station, uint256 units, uint256 cost);
    event SpaceNodeActivated(address indexed satellite, uint256 feePaid);

    constructor(address _autonTokenAddress) {
        architect = msg.sender;
        autonToken = IAutonToken(_autonTokenAddress);
    }

    // --- ENERGY MISSION ---
    // Robots/Drones energy kharidenge Solar Stations se
    function buyEnergy(address solarStation, uint256 units) public returns (bool) {
        uint256 cost = units * energyRate;
        require(autonToken.transferFrom(msg.sender, solarStation, cost), "Insaaniyat Check: Insufficient Auton");
        emit EnergyTraded(msg.sender, solarStation, units, cost);
        return true;
    }

    // --- SPACE MISSION ---
    // Satellites ko Auton Network par register karne ke liye
    function registerSpaceNode(address satelliteAddr) public returns (bool) {
        require(autonToken.transferFrom(msg.sender, architect, satelliteLinkFee), "Space Mission requires $AUTON fuel");
        emit SpaceNodeActivated(satelliteAddr, satelliteLinkFee);
        return true;
    }
}

