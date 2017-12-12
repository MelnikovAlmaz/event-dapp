pragma solidity ^0.4.18;


contract Event{
    // Constant
    uint EVENT_CHANGE_TIME = 3 * 1 days;

    string _name;
    uint _creation_time;
    uint _start_date;
    string _competence;

    mapping(address => uint) _marks;
    address[] _participants;
    address[] _experts;

    address _controller;

    struct Edition{
    string _name;
    uint _start_date;
    string _competence;
    address[] _participants;
    address[] _experts;
    }

    bool _isEditing;
    uint _acceptanceCount;
    mapping(address => bool) _isExpertAccepted;
    Edition _edition;

    function Event(string name, uint creation_time, uint start_date, string competence, address[] expert_list, address[] participant_list){
        // Init data of Event
        _name = name;
        _creation_time = creation_time;
        _start_date = start_date;
        _competence = competence;
        _experts = expert_list;
        _participants = participant_list;

        // Edition data Init
        _isEditing = false;
        _acceptanceCount = 0;

        // Init controller contract that can manage event
        _controller = msg.sender;
    }

    function submitAcceptence(address sender) onlyController public returns (bool){
        // Check is editing available
        require(_isEditing == true);
        if(_creation_time + EVENT_CHANGE_TIME > now){
            closeEventChange();
            return false;
        }
        else{
            // Check is it expert of Event
            require(isExpert(sender));
            require(_isExpertAccepted[sender] == false);

            _isExpertAccepted[sender] = true;
            _acceptanceCount += 1;

            return acceptEdition();
        }
    }

    function changeEvent(address sender, string name, uint start_date, string competence, address[] expert_list, address[] participant_list) onlyController changeAvailable public{
        // Check is it expert of Event
        require(isExpert(sender));
        // Form Event data structure
        _edition = Edition({
        _name: name,
        _start_date: start_date,
        _competence: competence,
        _experts: expert_list,
        _participants: participant_list
        });
        _isEditing = true;
        _acceptanceCount = 1;
        _isExpertAccepted[sender] = true;

        acceptEdition();
    }

    function acceptEdition() private returns (bool){
        // Check if Event has enought aceptance
        if(_experts.length == _acceptanceCount){
            // Add edition to Event
            _name = _edition._name;
            _start_date = _edition._start_date;
            _competence = _edition._competence;
            _experts = _edition._experts;
            _participants = _edition._participants;

            closeEventChange();
            return true;
        }
        else {
            return false;
        }
    }

    function closeEventChange() private {
        // Delete all experts votes
        for(uint i=0;i<_experts.length;i++){
            _isExpertAccepted[_experts[i]] = false;
        }
        _acceptanceCount = 0;
        _isEditing = false;
    }

    function isExpert(address sender) private returns (bool){
        bool is_expert = false;
        for(uint i=0;i<_experts.length;i++){
            if(_experts[i] == sender){
                is_expert = true;
                break;
            }
        }
        return is_expert;
    }
    modifier onlyController {
        require(msg.sender == _controller);
        _;
    }

    modifier changeAvailable {
        require(_isEditing == false);
        require(_acceptanceCount == 0);
        for(uint i=0;i<_experts.length;i++){
            require(_isExpertAccepted[_experts[i]] == false);
        }
        _;
    }
}