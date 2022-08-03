const Migrations = artifacts.require("Migrations");


const TrustAccessData = artifacts.require("TrustAccessData");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(TrustAccessData);
};
