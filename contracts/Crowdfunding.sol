pragma solidity^0.5.4;
import 'https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol';

contract Crowdfunding {
using SafeMath for uint256; 

    Project[] private projects; //Array to store list of existing projects4

    event ProjectStarted( //event that will be emitted everytime a new project is strated.

        address contractAddress,
        address projectStarter,
        string projectTitle,
        string projectDesc,
        uint256 deadline,
        uint256 goalAmount
    );

    function startProject(
        string calldata title,  //title of the project.
        string calldata description, //Description of the project.
        uint durationInDays, //number of days for which project would be open for funding.
        uint amountToRaise   //total amount of money to be raised for the funding.

    ) external {

        uint raiseUntil = now.add(durationInDays.mul(1 days));
        Project newProject = new Project(msg.sender, title, description, raiseUntil, amountToRaise);
        projects.push(newProject);
    
        emit ProjectStarted( //Triggering the event.
            address(newProject),
            msg.sender,
            title,
            description,
            raiseUntil,
            amountToRaise
        );
    }

    // function to return the contact address of all projects.
    //declared externally, as it can be called by other contracts.

    function returnAllProjects() external view returns (Project[] memory){ //other contracts and transaction can call this function.
        return projects;
    }
}

contract Project {

    using SafeMath for uint256;

    enum State {

        Fundraising,
        Expired,
        Successful
    }

    //Declaring State Variables.

    address payable public creator;
    uint public amountGoal;
    uint public completeAt;
    uint256 public currentBalance;
    uint public raiseBy;
    string public title;
    string public description;
    
    State public state = State.Fundraising; // initialise on create
    mapping (address => uint ) public contributions;

    event fundingRecieved (address contributor, uint amount, uint currentTotal);
    //event to be emitted whenever a funding will be recieved.

    event CreatorPaid (address recipient);
    //event to be emitted whenever project starter has recieved the funds.

    modifier inState(State _state){ //function modifier to check the current state

        require(state == state);
        _;

    }

    modifier isCreator() { //function modifier to check if function caller is creator.

        require(msg.sender == creator);
        _;

    }

    constructor (
        address payable projectStarter,
        string memory projectTitle,
        string memory projectDesc,
        uint fundRaisingDeadline,
        uint goalAmount

    ) public {

        creator = projectStarter;
        title = projectTitle;
        description = projectDesc;
        amountGoal = goalAmount;
        raiseBy = fundRaisingDeadline;
        currentBalance = 0;
    }


function contribute() external inState(State.Fundraising) payable { //function to fund a certain project.


        require(msg.sender != creator); //creator can't raise fund for himself.
        contributions[msg.sender] = contributions[msg.sender].add(msg.value);
        currentBalance = currentBalance.add(msg.value);
        emit fundingRecieved(msg.sender, msg.value, currentBalance);
        fundingStatus();
    }


function fundingStatus() public { //function to change the project's current state depending on the conditions.
        if (currentBalance >= amountGoal) {
            state = State.Successful;
            payOut();
        } else if (now > raiseBy)  {
            state = State.Expired;
        }
        completeAt = now;
    }
/* 
function payOut internal inState(State.Successful) returns (bool) { //fuction to give recieved funds to the project starter.
    uint256 totalRaised = currentBalance;
    currentBalance = 0;
    if (creator.send(totalRaised)) {
        emit creatorPaid(creator);
        return true;
    } else {
        currentBalance = totalRaised;
        state = State.Successful;
    }
    return false;
}
*/

function payOut() internal inState(State.Successful) returns (bool) {
        uint256 totalRaised = currentBalance;
        currentBalance = 0;

        if (creator.send(totalRaised)) {
            emit CreatorPaid(creator);
            return true;
        } else {
            currentBalance = totalRaised;
            state = State.Successful;
        }

        return false;
    }

function getRefund() public inState(State.Expired) returns (bool) { //function to return the funds to respective supporters in case the project is expired.
        require(contributions[msg.sender] > 0);

        uint amountToRefund = contributions[msg.sender];
        contributions[msg.sender] = 0;

        if (!msg.sender.send(amountToRefund)) {
            contributions[msg.sender] = amountToRefund;
            return false;
        } else {
            currentBalance = currentBalance.sub(amountToRefund);
        }

        return true;
    }


function getDetails() public view returns //function to retrieve the values of project.
(
    address payable projectStarter,
    string memory projectTitle,
    string memory projectDesc,
    uint256 deadline,
    State currentState,
    uint256 currentAmount,
    uint256 goalAmount
) {
    projectStarter = creator;
    projectTitle = title;
    projectDesc = description;
    deadline = raiseBy;
    currentState = state;
    currentAmount = currentBalance;
    goalAmount = amountGoal;
 }
}

