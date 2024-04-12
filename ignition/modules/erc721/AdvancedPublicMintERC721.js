const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("AdvancedPublicMintERC721Module", (m) => {

  const advancedPublicMintERC721 = m.contract("AdvancedPublicMintERC721", [
    "AdvancedPublicMintERC721", 
    "APM", 
    "ipfs://CID/"
  ]);

  return { advancedPublicMintERC721 };
});
