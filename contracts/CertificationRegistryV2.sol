// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CertificationRegistryV2 {
    struct Certification {
        address owner;
        address veterinarian;
        address registrar;
        uint256 timestamp;
        bytes32 documentHash;
        string animalId;
    }

    struct AnimalHistory {
        bytes32[] documentHashes;
        uint256[] timestamps;
    }

    mapping(bytes32 => Certification) public certifications;
    mapping(string => AnimalHistory) private animalHistories;
    
    event DocumentCertified(
        bytes32 indexed hash, 
        address indexed owner, 
        address veterinarian, 
        address registrar, 
        uint256 timestamp,
        string animalId
    );
    
    event DebugSignature(
        bytes32 messageHash,
        bytes32 ethSignedHash,
        address recovered,
        address expected,
        string sigType
    );

    /**
     * @dev Certifies a document with owner and veterinarian signatures
     * @param hash SHA256 hash of the PDF document
     * @param animalId Unique animal ID (CUIG or similar identifier)
     * @param owner Owner's address
     * @param veterinarian Veterinarian's address
     * @param ownerSig Owner's signature
     * @param vetSig Veterinarian's signature
     */
    function certifyDocument(
        bytes32 hash,
        string memory animalId,
        address owner,
        address veterinarian,
        bytes memory ownerSig,
        bytes memory vetSig
    ) public {
        require(certifications[hash].timestamp == 0, "Document already certified");
        require(owner != address(0), "Invalid owner address");
        require(veterinarian != address(0), "Invalid veterinarian address");
        require(bytes(animalId).length > 0, "Animal ID required");
        
        // Create the message to be signed
        bytes32 message = keccak256(abi.encodePacked(hash, owner, veterinarian));
        
        // Verify owner's signature
        address recoveredOwner = recoverSigner(message, ownerSig);
        emit DebugSignature(message, getEthSignedMessageHash(message), recoveredOwner, owner, "owner");
        require(recoveredOwner == owner, "Invalid owner signature");
        
        // Verify veterinarian's signature
        address recoveredVet = recoverSigner(message, vetSig);
        emit DebugSignature(message, getEthSignedMessageHash(message), recoveredVet, veterinarian, "vet");
        require(recoveredVet == veterinarian, "Invalid veterinarian signature");
        
        // Store certification
        certifications[hash] = Certification({
            owner: owner,
            veterinarian: veterinarian,
            registrar: msg.sender,
            timestamp: block.timestamp,
            documentHash: hash,
            animalId: animalId
        });
        
        // Add to animal's history
        animalHistories[animalId].documentHashes.push(hash);
        animalHistories[animalId].timestamps.push(block.timestamp);
        
        emit DocumentCertified(hash, owner, veterinarian, msg.sender, block.timestamp, animalId);
    }
    
    /**
     * @dev Recovers the signer of a message
     * @param message The original message (hash)
     * @param sig The signature
     */
    function recoverSigner(bytes32 message, bytes memory sig) public pure returns (address) {
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(message);
        return recover(ethSignedMessageHash, sig);
    }
    
    /**
     * @dev Adds the Ethereum prefix to the message
     */
    function getEthSignedMessageHash(bytes32 message) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message));
    }
    
    /**
     * @dev Recovers the signer's address
     * Accepts signatures of 64 or 65 bytes
     */
    function recover(bytes32 hash, bytes memory sig) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        
        // Support 64-byte (without v) and 65-byte (with v) signatures
        if (sig.length == 64) {
            // Compact signature without v - calculate v
            assembly {
                r := mload(add(sig, 32))
                s := mload(add(sig, 64))
            }
            // Try both possible values of v
            address addr1 = ecrecover(hash, 27, r, s);
            address addr2 = ecrecover(hash, 28, r, s);
            
            // Return the valid address (non-zero)
            if (addr1 != address(0)) return addr1;
            if (addr2 != address(0)) return addr2;
            revert("Invalid signature - could not recover");
            
        } else if (sig.length == 65) {
            // Standard signature with v included
            assembly {
                r := mload(add(sig, 32))
                s := mload(add(sig, 64))
                v := byte(0, mload(add(sig, 96)))
            }
            
            // Adjust v if necessary (27 or 28 for Ethereum)
            if (v < 27) {
                v += 27;
            }
            
            return ecrecover(hash, v, r, s);
            
        } else {
            revert("Invalid signature length - must be 64 or 65 bytes");
        }
    }
    
    /**
     * @dev Checks if a document is certified
     */
    function isCertified(bytes32 hash) public view returns (bool) {
        return certifications[hash].timestamp > 0;
    }
    
    /**
     * @dev Gets the details of a certification
     */
    function getCertification(bytes32 hash) public view returns (
        address owner,
        address veterinarian,
        address registrar,
        uint256 timestamp
    ) {
        Certification memory cert = certifications[hash];
        return (cert.owner, cert.veterinarian, cert.registrar, cert.timestamp);
    }
    
    /**
     * @dev Helper function for testing - verifies a signature
     */
    function testSignature(
        bytes32 hash,
        address signer,
        bytes memory signature
    ) public pure returns (bool valid, address recovered) {
        bytes32 message = getEthSignedMessageHash(hash);
        recovered = recover(message, signature);
        valid = (recovered == signer);
    }
    
    /**
     * @dev Gets all certification hashes for an animal ordered by date
     * @param animalId Animal ID
     * @return documentHashes Array of document hashes
     * @return timestamps Array of corresponding timestamps
     */
    function getAnimalHistory(string memory animalId) public view returns (
        bytes32[] memory documentHashes,
        uint256[] memory timestamps
    ) {
        AnimalHistory memory history = animalHistories[animalId];
        return (history.documentHashes, history.timestamps);
    }
    
    /**
     * @dev Gets the number of certifications for an animal
     * @param animalId Animal ID
     * @return count Number of certifications
     */
    function getAnimalCertificationCount(string memory animalId) public view returns (uint256) {
        return animalHistories[animalId].documentHashes.length;
    }
    
    /**
     * @dev Gets the latest certification for an animal
     * @param animalId Animal ID
     * @return hash Hash of the latest certified document
     * @return timestamp Timestamp of the latest certification
     */
    function getLatestAnimalCertification(string memory animalId) public view returns (
        bytes32 hash,
        uint256 timestamp
    ) {
        AnimalHistory memory history = animalHistories[animalId];
        require(history.documentHashes.length > 0, "No certifications for this animal");
        
        uint256 lastIndex = history.documentHashes.length - 1;
        return (history.documentHashes[lastIndex], history.timestamps[lastIndex]);
    }
    
    /**
     * @dev Checks if an animal has certifications
     * @param animalId Animal ID
     * @return exists True if the animal has at least one certification
     */
    function animalExists(string memory animalId) public view returns (bool) {
        return animalHistories[animalId].documentHashes.length > 0;
    }
}