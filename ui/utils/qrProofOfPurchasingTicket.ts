export const qrProofOfPurchasingTicket = {
  "id": "7f38a193-0918-4a48-9fac-36adfdb8b542",
  "typ": "application/iden3comm-plain-json",
  "type": "https://iden3-communication.io/proofs/1.0/contract-invoke-request",
  "thid": "7f38a193-0918-4a48-9fac-36adfdb8b542",
  "body": {
      "reason": "purchase event ticket",
      "transaction_data": {
          "contract_address": "0x3bc536fFeffc62DE1F52351B9bD7543Ad44D4a5E",
          "method_id": "b68967e2",
          "chain_id": 80001,
          "network": "polygon-mumbai"
      },
      "scope": [
          {
              "id": 1,
              "circuitId": "credentialAtomicQuerySigV2OnChain",
              "query": {
                  "allowedIssuers": [
                      "*"
                  ],
                  "context": "https://raw.githubusercontent.com/0xPolygonID/tutorial-examples/main/credential-schema/schemas-examples/proof-of-humanity/proof-of-humanity.json",//"https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json-ld/kyc-v3.json-ld",
                  "credentialSubject": {
                      "isHuman": {
                          "$eq": 1
                      }
                  },
                  "type": "ProofOfHumanity"
              }
          }
      ]
  }
}