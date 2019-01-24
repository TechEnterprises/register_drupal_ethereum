pragma solidity ^0.5.0;
import "../node_modules/zos-lib/contracts/Initializable.sol";

contract RegisterDrupal is Initializable {

    // Mapping that matches Drupal generated hash with Ethereum Account address.
    mapping (bytes32 => address) _accounts;

    // Event allowing listening to newly signed Accounts (?)
    event AccountCreated (address indexed from, bytes32 hash);

    address _registryAdmin;

    // Allowed to administrate accounts only, not everything
    address _accountAdmin;

    // If a newer version of this registry is available, force users to use it
    bool _registrationDisabled;

    // Register Account
    function newUser(bytes32 hash) public {

        if (_accounts[hash] == msg.sender) {
            // Hash all ready registered to address.
            revert("Hash already registered to address.");
        }
        else if (uint(_accounts[hash]) > 0) {
            // Hash all ready registered to different address.
            revert("Hash already registered to different address.");
        }
        else if (hash.length > 32) {
            // Hash too long
            revert("Hash too long.");

        }
        else if (_registrationDisabled){
            // Registry is disabled because a newer version is available
            revert("Registry is disabled because a newer version is available.");
        }
        else {
            _accounts[hash] = msg.sender;
            emit AccountCreated(msg.sender, hash);
        }
    }

    // Validate Account
    // This function is actually not necessary if you implement Event handling in PHP.
    function validateUserByHash (bytes32 hash) public view returns (address result) {
        return _accounts[hash];
    }

    function contractExists () public pure returns (bool result){
        return true;
    }

    // Administrative below
    constructor() public {
        _registryAdmin = msg.sender;
        _accountAdmin = msg.sender; // can be changed later
        _registrationDisabled = false;
    }

    function adminSetRegistrationDisabled(bool registrationDisabled) public {
        // currently, the code of the registry can not be updated once it is
        // deployed. if a newer version of the registry is available, account
        // registration can be disabled
        if (msg.sender == _registryAdmin) {
            _registrationDisabled = registrationDisabled;
        }
    }

    function adminSetAccountAdministrator(address accountAdmin) public {
        if (msg.sender == _registryAdmin) {
            _accountAdmin = accountAdmin;
        }
    }

    function adminRetrieveDonations() public {
        if (msg.sender == _registryAdmin) {
            msg.sender.transfer(address(this).balance);
        }
    }
}
