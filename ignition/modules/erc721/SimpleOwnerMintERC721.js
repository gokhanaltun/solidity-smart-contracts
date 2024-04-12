const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("SimpleOwnerMintERC721Module", (m) => {

  const simpleOwnerMintERC721 = m.contract("SimpleOwnerMintERC721", ["SimpleOwnerMintERC721", "SOM"]);

  return { simpleOwnerMintERC721 };
});
