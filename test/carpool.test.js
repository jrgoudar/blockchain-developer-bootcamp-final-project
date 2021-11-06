let BN = web3.utils.BN;
let CarPoolDApp = artifacts.require("CarPoolDApp");
//let { catchRevert } = require("./exceptionsHelpers.js");
//const { items: ItemStruct, isDefined, isPayable, isType } = require("./ast-helper");

contract("CarPoolDApp", function (accounts) {
  const [_owner, alice, bob] = accounts;
  const emptyAddress = "0x0000000000000000000000000000000000000000";

  const price = "1000";
  const excessAmount = "2000";
  const name = "book";

  let instance;

  beforeEach(async () => {
    instance = await CarPoolDApp.new();
  });

  describe("Variables", () => {

    it("should have an parentCount", async () => {
      assert.equal(typeof instance.parentCount, 'function', "the contract has no parentCount");
    });
});

describe("UseCases", () => {

    it("should have an parentCount", async () => {
      assert.equal(typeof instance.parentCount, 'function', "the contract has no parentCount");
    });
});



});