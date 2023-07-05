const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BankAccount", function () {
  async function deployBankAccount() {
    // Contracts are deployed using the first signer/account by default
    const [addr0, addr1, addr2, addr3] = await ethers.getSigners();

    const BankAccount = await ethers.getContractFactory("BankAccount");
    const bankAccount = await BankAccount.deploy();

    return { bankAccount, addr0, addr1, addr2, addr3 };

    describe("Deployment", () => {
      it("Should deploy without error", async () => {
        await loadFixture(deployBankAccount);
      });
    });
  }
});
