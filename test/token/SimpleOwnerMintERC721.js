const {
    loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");

describe("SimpleOwnerMintERC721", () => {
    /**
     * @dev defining a fixture to reuse the same setup in every test.
     */
    const deployFixture = async () => {

        const tokenName = "SimpleOwnerMintTest";
        const tokenSymbol = "SOMT";

        const [owner, otherAccount] = await ethers.getSigners();
        const SimpleOwnerMintERC721 = await ethers.getContractFactory("SimpleOwnerMintERC721");
        const simpleOwnerMintERC721 = await SimpleOwnerMintERC721.deploy(tokenName, tokenSymbol);

        return { simpleOwnerMintERC721, tokenName, tokenSymbol, owner, otherAccount };
    }

    describe("Deployment", () => {
        it("Should set the right tokenName", async () => {
            const { simpleOwnerMintERC721, tokenName } = await loadFixture(deployFixture);

            expect(await simpleOwnerMintERC721.name()).to.equal(tokenName);
        });

        it("Should set the right tokenSymbol", async () => {
            const { simpleOwnerMintERC721, tokenSymbol } = await loadFixture(deployFixture);

            expect(await simpleOwnerMintERC721.symbol()).to.equal(tokenSymbol);
        });

        it("Should set the right owner", async () => {
            const { simpleOwnerMintERC721, owner } = await loadFixture(deployFixture);

            expect(await simpleOwnerMintERC721.owner()).to.equal(owner);
        });
    });

    describe("Minting", () => {
        it("Should owner can mint", async () => {
            const { owner, simpleOwnerMintERC721 } = await loadFixture(deployFixture);
            const tokenId = 1;

            await simpleOwnerMintERC721.safeMint(owner, tokenId);

            expect(await simpleOwnerMintERC721.ownerOf(tokenId)).to.equal(owner);
        });

        it("Should other can't mint", async () => {
            const { otherAccount, simpleOwnerMintERC721 } = await loadFixture(deployFixture);
            const tokenId = 2;

            await simpleOwnerMintERC721.safeMint(otherAccount, tokenId);

            expect(await simpleOwnerMintERC721.ownerOf(tokenId)).to.be.revertedWith("OwnableUnauthorizedAccount");
        });
    });
    
    describe("Token URI", () => {
        it("Should get the right tokenURI", async () => {
            const {owner, simpleOwnerMintERC721 } = await loadFixture(deployFixture);
            
            const tokenURI = "YOUR_BASE_URI_HERE1.json"
            const tokenId = 1;

            await simpleOwnerMintERC721.safeMint(owner, tokenId);

            expect(await simpleOwnerMintERC721.tokenURI(tokenId)).to.equal(tokenURI);
        });
    });
});