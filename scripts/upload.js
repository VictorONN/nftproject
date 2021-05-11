/* eslint no-use-before-define: "warn" */
const fs = require("fs");
const chalk = require("chalk");
const { config, ethers } = require("hardhat");
const { utils } = require("ethers");
const R = require("ramda");
const ipfsAPI = require('ipfs-http-client');
const ipfs = ipfsAPI({host: 'ipfs.infura.io', port: '5001', protocol: 'https' })
const{ NFTStorage, Blob } = require('nft.storage')

const apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweEQwRTE1QTU3ZjlmNDlBMUIzZThmZjJENTMyOTU1NDAzNENkMDg4NDgiLCJpc3MiOiJuZnQtc3RvcmFnZSIsImlhdCI6MTYyMDcxOTg3NTQyNiwibmFtZSI6ImZpcnN0In0.p136rpxgJJlLodwkKPpukWD1_oR9bl3xigTq_3mprv4'
const client = new NFTStorage({ token: apiKey})

const main = async () => {
  const artwork = JSON.parse(fs.readFileSync('./artwork.json').toString())
  const allAssets = await Promise.all(artwork.map(async item => {
      // const uploaded = await ipfs.add(JSON.stringify(item))
      const content = new Blob(JSON.stringify(item))
      const cid = await client.storeBlob(content)
      // return {
      //   ...item,
      //   updateInfo: `ipfs://${uploaded.path}`
      // }
      return {
        ...item,
        updateInfo: `ipfs://${cid}`
      }
    }
  ))
  fs.writeFileSync('./uploaded.json', JSON.stringify(allAssets))
}


// function sleep(ms) {
//   return new Promise(resolve => setTimeout(resolve, ms));
// }

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

