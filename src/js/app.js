App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    // Load addresses
    
    return App.initWeb3();
  },

  initWeb3: function() {
    // Is there is an injected web3 instance?
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
    } else {
      // If no injected web3 instance is detected, fallback to the TestRPC
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
    }
    web3 = new Web3(App.web3Provider);

    //return App.initContract();
  },

  initContract: function() {
// TESTRPC load:
    $.getJSON('HumanStandardToken.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var TokenTArtifact = data;

      // ROPSTENL USING deployed contract:
      App.contracts.Token = TruffleContract(TokenTArtifact);                                // Set contract ABI
      // Set the provider for our contract
      App.contracts.Token.setProvider(App.web3Provider);

      // Use our contract to retrieve and mark the adopted pets
      return App.getBCTBalances();
    });


  },

  bindEvents: function() {

  },

  getBCTBalances: function() {
    $.getJSON('../students.json', function(data) {
      data.forEach(function(student,i,data){
        return App.getBCTBalance(student.address);
      });
    });
  },

  getBCTBalance: function(address, account) {
    App.contracts.Token.at('0x220392e76058BAd0798E16F16987093EBB0944DB').then(function(instance) {
      Tokennstance = instance;
      return Tokennstance.balanceOf.call(address);
    }).then(function(balance){
      $('#'+address).text(balance);
    }).catch(function(err) {
      console.log(err.message);
    });
  },

  handleAdopt: function(event) {

  }

};

function createEvent() {
    var event_data = {};
    event_data["event_name"] = $("#name").val();
    event_data["competence_name"] = $("#competence_name").val();
    event_data["creation_date"] = $("#creation_date").val();
    var expert_string = $("#expert_list").val();
    console.log(expert_string);
    event_data["address_list"] = expert_string.split("\n");
    event_data["participant_list"] = [];

    node.files.add(Buffer.from(event_data), (err, file) => {
        if (err) { return onError(err) }

        const fl = file[0];
        $("#multihash").value = fl.hash;
        console.log(fl.hash);
    });
}
$(function() {
  $(window).load(function() {
    App.init();
    start();
    $("#create_event_btn").click(createEvent);
  });
});
