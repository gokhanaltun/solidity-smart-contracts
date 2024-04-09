const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { BigInt } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AdvancedPublicMintERC721", () => {
    /**
     * @dev defining a fixture to reuse the same setup in every test.
     */
    const deployFixture = async () => {
        const tokenName = "AdvancedPublicMintTest";
        const tokenSymbol = "APMT";
        const baseURI = "ipfs://CID/";

        const [owner, otherAccount] = await ethers.getSigners();
        const contractFactory = await ethers.getContractFactory("AdvancedPublicMintERC721");
        const contract = await contractFactory.deploy(tokenName, tokenSymbol, baseURI);

        return { contract, tokenName, tokenSymbol, baseURI, owner, otherAccount };
    }

    describe("Deployment", () => {

        it("Should set the right tokenName", async () => {
            const { contract, tokenName } = await loadFixture(deployFixture);

            expect(await contract.name()).to.equal(tokenName);
        });

        it("Should set the right tokenSymbol", async () => {
            const { contract, tokenSymbol } = await loadFixture(deployFixture);

            expect(await contract.symbol()).to.equal(tokenSymbol);
        });
    });

    describe("Mint Limit Functions", () => {

        describe("Setters", () => {
            it("Should owner can set the maxMintCount", async () => {
                const { contract } = await loadFixture(deployFixture);

                expect(await contract.setMaxMintCount(100)).not.to.be.revertedWith("OwnableUnauthorizedAccount");
            });

            it("Should owner can set the maxMintCountPerAddress", async () => {
                const { contract } = await loadFixture(deployFixture);

                await contract.setMaxMintCount(100);
                expect(await contract.setMaxMintCountPerAddress(10)).not.to.be.revertedWith("OwnableUnauthorizedAccount");
            });

            it("Should revertedWith MaxMintLimitPerAddressExceedsTotalSupply error", async () => {
                const { contract } = await loadFixture(deployFixture);

                await contract.setMaxMintCount(10);
                await expect(contract.setMaxMintCountPerAddress(11)).to.be.revertedWithCustomError(
                    contract,
                    'MaxMintLimitPerAddressExceedsTotalSupply'
                );
            });

            it("Should other can't set the maxMintCount", async () => {
                const { contract, otherAccount } = await loadFixture(deployFixture);

                await expect(contract.connect(otherAccount).setMaxMintCount(100)).to.be.revertedWithCustomError(
                    contract,
                    'OwnableUnauthorizedAccount'
                );
            });

            it("Should other can't set the maxMintCountPerAddress", async () => {
                const { contract, otherAccount } = await loadFixture(deployFixture);

                await contract.setMaxMintCount(100);
                await expect(contract.connect(otherAccount).setMaxMintCountPerAddress(10)).to.be.revertedWithCustomError(
                    contract,
                    "OwnableUnauthorizedAccount"
                );
            });

        });

        describe("Getters", () => {
            it("Should get the right maxMintCount", async () => {
                const { contract } = await loadFixture(deployFixture);
                const maxMintCount = 100;

                await contract.setMaxMintCount(maxMintCount);
                expect(await contract.getMaxMintCount()).to.equal(maxMintCount);
            });

            it("Should get the right maxMintCountPerAddress", async () => {
                const { contract } = await loadFixture(deployFixture);
                const maxMintCount = 100;
                const maxMintCountPerAddress = 10;

                await contract.setMaxMintCount(maxMintCount);
                await contract.setMaxMintCountPerAddress(maxMintCountPerAddress);

                expect(await contract.getMaxMintCountPerAddress()).to.equal(maxMintCountPerAddress);
            });

        });
    });

    describe("Mint Amount Function", () => {
        describe("Setter", () => {
            it("Should owner can set the max mint amount", async () => {
                const { contract } = await loadFixture(deployFixture);

                const mintAmount = ethers.parseEther("1");

                await expect(contract.setMintAmount(mintAmount)).not.to.be.revertedWithCustomError(
                    contract,
                    "OwnableUnauthorizedAccount"
                );
            });

            it("Should other can't set the max mint amount", async () => {
                const { contract, otherAccount } = await loadFixture(deployFixture);

                const mintAmount = ethers.parseEther("1");

                await expect(contract.connect(otherAccount).setMintAmount(mintAmount)).to.be.revertedWithCustomError(
                    contract,
                    "OwnableUnauthorizedAccount"
                );
            });
        });

        describe("Getter", () => {
            it("Should get the right max mint amount", async () => {
                const { contract } = await loadFixture(deployFixture);
                const mintAmount = ethers.parseEther("1");

                await contract.setMintAmount(mintAmount)
                expect(await contract.mintAmount()).to.equal(mintAmount);

            });
        });

    });

    describe("Set Base URI Function", () => {
        it("Should owner can set the baseURI", async () => {
            const { contract } = await loadFixture(deployFixture);
            const newBaseURI = "ipfs://NEW_CID/";

            await expect(contract.setBaseTokenURI(newBaseURI)).not.to.be.revertedWithCustomError(
                contract,
                "OwnableUnauthorizedAccount"
            );
        });

        it("Should other can't set the baseURI", async () => {
            const { contract, otherAccount } = await loadFixture(deployFixture);
            const newBaseURI = "ipfs://NEW_CID/";

            await expect(contract.connect(otherAccount).setBaseTokenURI(newBaseURI)).to.be.revertedWithCustomError(
                contract,
                "OwnableUnauthorizedAccount"
            );
        });

        it("Should owner can set the right baseURI", async () => {
            const { owner, contract } = await loadFixture(deployFixture);
            const newBaseURI = "ipfs://NEW_CID/";
            const mintAmount = ethers.parseEther("1");

            await contract.setBaseTokenURI(newBaseURI);
            await contract.setMaxMintCount(2);
            await contract.setMaxMintCountPerAddress(1);
            await contract.setMintAmount(mintAmount);
            await contract.safeMint(owner, { value: mintAmount });

            const currentMintCount = await contract.getCurrentMintCount();
            const expected = `ipfs://NEW_CID/${currentMintCount}.json`;

            expect(await contract.tokenURI(currentMintCount)).to.equal(expected);
        });
    });

    describe("Safe Mint Function", () => {
        describe("Limits", () => {
            it("Should revert with MaxTotalSupplyReached error", async () => {
                const { owner, otherAccount, contract } = await loadFixture(deployFixture);
                const mintAmount = ethers.parseEther("0.5");

                await contract.setMaxMintCount(1);
                await contract.setMaxMintCountPerAddress(1);
                await contract.safeMint(owner, { value: mintAmount });

                await expect(contract.safeMint(otherAccount)).to.be.revertedWithCustomError(
                    contract,
                    "MaxTotalSupplyReached"
                );
            });

            it("Should revert with AddressMintLimitReached error", async () => {
                const { owner, contract } = await loadFixture(deployFixture);
                const mintAmount = ethers.parseEther("0.5");

                await contract.setMaxMintCount(2);
                await contract.setMaxMintCountPerAddress(1);
                await contract.safeMint(owner, { value: mintAmount });

                await expect(contract.safeMint(owner)).to.be.revertedWithCustomError(
                    contract,
                    "AddressMintLimitReached"
                );
            });
        });

        describe("Payment", () => {
            it("Should reverted with InvalidPayment error for lower payment", async () => {
                const { owner, contract } = await loadFixture(deployFixture);
                const mintAmount = ethers.parseEther("0.4");

                await contract.setMaxMintCount(2);
                await contract.setMaxMintCountPerAddress(1);

                await expect(contract.safeMint(owner, { value: mintAmount })).to.be.revertedWithCustomError(
                    contract,
                    "InvalidPayment"
                );
            });

            it("Should revert with InvalidPayment error for higher payment", async () => {
                const { owner, contract } = await loadFixture(deployFixture);
                const mintAmount = ethers.parseEther("1");

                await contract.setMaxMintCount(2);
                await contract.setMaxMintCountPerAddress(1);

                await expect(contract.safeMint(owner, { value: mintAmount })).to.be.revertedWithCustomError(
                    contract,
                    "InvalidPayment"
                );
            });
        });
    });

    describe("Token URI Function", () => {
        it("Should return the right tokenURI", async () => {
            const { owner, contract, baseURI } = await loadFixture(deployFixture);
            const mintAmount = ethers.parseEther("0.5");

            await contract.setMaxMintCount(2);
            await contract.setMaxMintCountPerAddress(1);
            await contract.safeMint(owner, { value: mintAmount });

            const currentMintCount = await contract.getCurrentMintCount();
            const expected = `${baseURI}${currentMintCount}.json`;

            expect(await contract.tokenURI(currentMintCount)).to.equal(expected);
        });
    });

    describe("Withdraw Function", () => {
        it("Should owner can withdraw", async () => {
            const { owner, contract } = await loadFixture(deployFixture);
            const mintAmount = ethers.parseEther("0.5");
            const ownerBalanceBefore = await ethers.provider.getBalance(owner.address);
            let totalCost = 0n;
            
            const tx1 = await contract.setMaxMintCount(2);
            const tx1Receipt = await tx1.wait();
            totalCost += tx1Receipt.gasUsed * tx1Receipt.gasPrice;

            const tx2 = await contract.setMaxMintCountPerAddress(1);
            const tx2Receipt = await tx2.wait();
            totalCost += tx2Receipt.gasUsed * tx2Receipt.gasPrice;

            const tx3 = await contract.safeMint(owner, { value: mintAmount });
            const tx3Receipt = await tx3.wait();
            totalCost += tx3Receipt.gasUsed * tx3Receipt.gasPrice;

            const tx4 = await contract.withdraw();
            const tx4Receipt = await tx4.wait();
            totalCost += tx4Receipt.gasUsed * tx4Receipt.gasPrice;

            const ownerBalanceAfter = await ethers.provider.getBalance(owner.address);

            expect(ownerBalanceAfter).to.equal(ownerBalanceBefore - totalCost);
        });

        it("Should other can't withdraw", async () => {
            const { otherAccount, contract } = await loadFixture(deployFixture);
            

            await expect(contract.connect(otherAccount).withdraw()).to.be.revertedWithCustomError(
                contract,
                "OwnableUnauthorizedAccount"
            );
        });
    });
});