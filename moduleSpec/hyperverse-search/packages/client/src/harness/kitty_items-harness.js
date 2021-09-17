import "../components/page-panel.js";
import "../components/page-body.js";
import "../components/action-card.js";
import "../components/account-widget.js";
import "../components/text-widget.js";
import "../components/number-widget.js";
import "../components/switch-widget.js";
import "../components/array-widget.js"
import "../components/dictionary-widget.js"

import DappLib from "@decentology/dappstarter-dapplib";
import { LitElement, html, customElement, property } from "lit-element";

@customElement('kitty-items-harness')
export default class KittyItemsHarness extends LitElement {
  @property()
  title;
  @property()
  category;
  @property()
  description;

  createRenderRoot() {
    return this;
  }

  constructor(args) {
    super(args);
  }

  render() {
    let content = html`
      <page-body title="${this.title}" category="${this.category}" description="${this.description}">

      
        <!-- Kibble -->
      
        <action-card title="Kibble - Setup Account" description="Setup Account" action="kibbleSetupAccount" method="post"
          fields="signer">
          <account-widget field="signer" label="Signer" placeholder="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="Kibble - Mint Tokens" description="Mint Tokens" action="kibbleMintTokens" method="post"
          fields="recipient amount">
          <account-widget field="recipient" label="Recipient" placeholder="Recipient">
          </account-widget>
          <text-widget field="amount" label="Amount" placeholder="30.0"></text-widget>
        </action-card>
      
        <action-card title="Kibble - Transfer Tokens" description="Transfer Tokens" action="kibbleTransferTokens"
          method="post" fields="signer amount to">
          <account-widget field="signer" label="Signer" placeholder="Signer">
          </account-widget>
          <text-widget field="amount" label="Amount" placeholder="30.0"></text-widget>
          <account-widget field="to" label="To" placeholder="To">
          </account-widget>
        </action-card>
      
        <action-card title="Kibble - Get Balance" description="Get Balance" action="kibbleGetBalance" method="get"
          fields="address">
          <account-widget field="address" label="Address" placeholder="Address">
          </account-widget>
        </action-card>
      
        <action-card title="Kibble - Get Supply" description="Get Supply" action="kibbleGetSupply" method="get" fields="">
        </action-card>
      
        <!-- Kitty Items -->
      
        <action-card title="Kitty Items - Setup Account" description="Setup Account" action="kittyItemsSetupAccount"
          method="post" fields="signer">
          <account-widget field="signer" label="Signer" placeholder="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="Kitty Items - Mint Kitty Item" description="Mint Kitty Item" action="kittyItemsMintKittyItem"
          method="post" fields="recipient typeID">
          <account-widget field="recipient" label="Recipient" placeholder="Recipient">
          </account-widget>
          <text-widget field="typeID" label="Type ID" placeholder="5"></text-widget>
        </action-card>
      
        <action-card title="Kitty Items - Transfer Kitty Item" description="Transfer Kitty Item"
          action="kittyItemsTransferKittyItem" method="post" fields="signer recipient withdrawID">
          <account-widget field="signer" label="Signer" placeholder="Signer">
          </account-widget>
          <account-widget field="recipient" label="Recipient" placeholder="Recipient">
          </account-widget>
          <text-widget field="withdrawID" label="Withdraw ID" placeholder="0"></text-widget>
        </action-card>
      
        <action-card title="Kitty Items - Read Collection IDs" description="Read Collection IDs"
          action="kittyItemsReadCollectionIDs" method="get" fields="address">
          <account-widget field="address" label="Address" placeholder="Address">
          </account-widget>
        </action-card>
      
        <action-card title="Kitty Items - Read Collection Length" description="Read Collection Length"
          action="kittyItemsReadCollectionLength" method="get" fields="address">
          <account-widget field="address" label="Address" placeholder="Address">
          </account-widget>
        </action-card>
      
        <action-card title="Kitty Items - Read Kitty Item Type ID" description="Read Kitty Item Type ID"
          action="kittyItemsReadKittyItemTypeID" method="get" fields="address itemID">
          <account-widget field="address" label="Address" placeholder="Address">
          </account-widget>
          <text-widget field="itemID" label="Item ID" placeholder="0"></text-widget>
        </action-card>
      
        <action-card title="Kitty Items - Read Kitty Items Supply" description="Read Kitty Items Supply"
          action="kittyItemsReadKittyItemsSupply" method="get" fields="">
        </action-card>
      
        <!-- Market-->
      
        <action-card title="Kitty Items Market - Setup Account" description="Setup Account"
          action="kittyItemsMarketSetupAccount" method="post" fields="signer">
          <account-widget field="signer" label="Signer" placeholder="Signer">
          </account-widget>
        </action-card>
      
        <action-card title="Kitty Items Market - Sell Market Item" description="Sell Market Item"
          action="kittyItemsMarketSellMarketItem" method="post" fields="signer itemID price">
          <account-widget field="signer" label="Signer" placeholder="Signer">
          </account-widget>
          <text-widget field="itemID" label="Item ID" placeholder="0"></text-widget>
          <text-widget field="price" label="Price" placeholder="30.0"></text-widget>
        </action-card>
      
        <action-card title="Kitty Items Market - Remove Market Item" description="Remove Market Item"
          action="kittyItemsMarketRemoveMarketItem" method="post" fields="signer itemID">
          <account-widget field="signer" label="Signer" placeholder="Signer">
          </account-widget>
          <text-widget field="itemID" label="Item ID" placeholder="0"></text-widget>
        </action-card>
      
        <action-card title="Kitty Items Market - Buy Market Item" description="Buy Market Item"
          action="kittyItemsMarketBuyMarketItem" method="post" fields="signer itemID marketCollectionAddress">
          <account-widget field="signer" label="Signer" placeholder="Signer">
          </account-widget>
          <text-widget field="itemID" label="Item ID" placeholder="0"></text-widget>
          <account-widget field="marketCollectionAddress" label="Market Collection Address"
            placeholder="Market Collection Address">
          </account-widget>
        </action-card>
      
        <action-card title="Kitty Items Market - Read Collection IDs" description="Read Collection IDs"
          action="kittyItemsMarketReadCollectionIDs" method="get" fields="address">
          <account-widget field="address" label="Address" placeholder="Address">
          </account-widget>
        </action-card>
      
        <action-card title="Kitty Items Market - Read Collection Length" description="Read Collection Length"
          action="kittyItemsMarketReadCollectionLength" method="get" fields="marketCollectionAddress">
          <account-widget field="marketCollectionAddress" label="Market Collection Address"
            placeholder="Market Collection Address">
          </account-widget>
        </action-card>

      
      </page-body>
      <page-panel id="resultPanel"></page-panel>
    `;

    return content;
  }
}
