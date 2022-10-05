import { anyValue } from '@nomicfoundation/hardhat-chai-matchers/withArgs';
import { time, loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';
import { ethers } from 'hardhat';

describe('Lock', function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployDexFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Dex = await ethers.getContractFactory('Dex');
    const dex = await Dex.deploy();

    const Token = await ethers.getContractFactory('SwappableToken');
    const tokenA = await Token.deploy(dex.address, 'tokenA', 'AAA', 10);
    const tokenB = await Token.deploy(dex.address, 'tokenB', 'BBB', 10);

    await dex.setTokens(tokenA.address, tokenB.address);

    const HackDex = await ethers.getContractFactory('HackDex');
    const hackDex = await HackDex.deploy();

    await hackDex.setDex(dex.address);
    await hackDex.setTokens(tokenA.address, tokenB.address);

    await tokenA.transfer(hackDex.address, tokenA.balanceOf(owner.address));
    await tokenB.transfer(hackDex.address, tokenB.balanceOf(owner.address));

    await hackDex.approveDex();

    return { dex, tokenA, tokenB, hackDex, owner, otherAccount };
  }

  describe('Deployment', function () {
    it('Should set the right balance', async function () {
      const { dex, tokenA, tokenB, hackDex } = await loadFixture(
        deployDexFixture
      );
      expect(await tokenA.balanceOf(dex.address)).to.be.equal(100);
      expect(await tokenB.balanceOf(dex.address)).to.be.equal(100);
      expect(await tokenA.balanceOf(hackDex.address)).to.be.equal(10);
      expect(await tokenB.balanceOf(hackDex.address)).to.be.equal(10);
    });

    it('Should drain balance of dex', async function () {
      const { dex, tokenA, tokenB, hackDex } = await loadFixture(
        deployDexFixture
      );
      await hackDex.drain();
      expect(await tokenA.balanceOf(dex.address)).to.be.equal(0);
      expect(await tokenB.balanceOf(dex.address)).to.be.equal(90);
    });
  });
});
