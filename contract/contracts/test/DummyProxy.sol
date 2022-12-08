// SPDX-License-Identifier: MIT

/*
 * Created by Satoshi Nakajima (@snakajima)
 */

pragma solidity ^0.8.6;

import '../external/opensea/IProxyRegistry.sol';

contract DummyProxy is IProxyRegistry {
  function proxies(address _address) external pure override returns (address) {
    return _address; // any address is fine
  }
}
