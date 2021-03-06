(function() {
  window.lo = window.lo || {};

  var NewOrderTemplate = React.createClass({
    propTypes: {
      baseUrl: React.PropTypes.string.isRequired
    },

    getInitialState: function() {
      return {
        name: "",
        error: false
      };
    },

    newName: function(event) {
      this.setState({name: event.target.value});
    },

    inputDisabled: function() {
      return (this.state.name.length === 0);
    },

    save: function() {
      var self = this;
      self.setState({error: false});
      $.ajax({
        type: 'POST',
        url: this.props.baseUrl + 'order_templates',
        data: {
          cart_id: this.props.cart.id,
          name: this.state.name
        },
        success: function(res) {
          window.location = res.url;
        },
        error: function(err) {
          self.setState({error: true});
        }
      });
    },

    render: function() {
      var itemRows = _.map(this.props.cart.items, function(item) {
        return (
          <tr>
            <td>{item.product.name} ({item.product.unit.plural})</td>
            <td>{item.quantity}</td>
          </tr>
        );
      });

      var error = (this.state.error) ? <div className="flash flash--warning"><p>There was an issue saving your new template. Please make sure that your template's name is unique.</p></div> : null;

      return (
        <div>
          <h1>New Order Template</h1>
          <table>
            <tbody>
              <tr>
                <th>Product Name</th>
                <th>Quantity</th>
              </tr>
              {itemRows}
            </tbody>
          </table>
          <div className="row" style={{marginTop: "50px"}}>
            <div className="column column--half">
              <label>Template name</label>
              <input value={this.state.name} onChange={this.newName} type="text" style={{width: "100%"}} className="app-template-name"/>
            </div>
            <div className="column column--half">
              <br/>
              <button type="button" disabled={this.inputDisabled()} className="btn--save pull-right app-save-template" onClick={this.save}>Save</button>
              <a href="/cart" className="btn pull-right" style={{marginRight: "20px"}}>Cancel</a>
            </div>
          </div>
          {error}
        </div>
      );
    }
  });

  window.lo.NewOrderTemplate = NewOrderTemplate;
}).call(this);
