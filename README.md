# Lightstreamer StockList Demo Client for ASP.NET AJAX#

This project includes an integration demo of Lightstreamer and Ajax Control Toolkit for [Microsoft ASP.NET](http://ajax.asp.net/).

## Lightstreamer ASP.NET AJAX Demo ##

<table>
  <tr>
    <td style="text-align: left">
      &nbsp;<a href="http://demos.lightstreamer.com/AtlasDemo" target="_blank"><img src="http://www.lightstreamer.com/img/demo/screen_atlas.png"></a>&nbsp;
      
    </td>
    <td>
      &nbsp;An online demonstration is hosted on our servers at:<br>
      &nbsp;<a href="http://demos.lightstreamer.com/AtlasDemo" target="_blank">http://demos.lightstreamer.com/AtlasDemo</a>
    </td>
  </tr>
</table>

This application uses the <b>JavaScript Client API for Lightstreamer</b> to handle the communications with Lightstreamer Server and uses an [Ajax Toolkit ReorderList control](http://www.asp.net/ajaxlibrary/act_ReorderList.ashx) to display the data for eight stock quotes received from the server.
The [Ajax Toolkit DragPanel ](http://www.asp.net/ajaxlibrary/act_DragPanel.ashx) and [CollapsiblePanel](http://www.asp.net/ajaxlibrary/act_CollapsiblePanel.ashx) controls are also used in the demo.<br>
You can drag the blue handles to reorder the list. Click on the stock names to open pop-up boxes showing the streaming charts.<br>

The demo includes the following client-side technologies:
* A [Subscription](http://www.lightstreamer.com/docs/client_javascript_uni_api/Subscription.html) for each of the eight stock quotes added to the update panel, subscribed to in <b>MERGE</b> mode feeding both a [StaticGrid](http://www.lightstreamer.com/docs/client_javascript_uni_api/StaticGrid.html) and, if opened, a [Chart](http://www.lightstreamer.com/docs/client_javascript_uni_api/Chart.html) for the pop-up window. 

# Deploy #

The example is comprised of the following source code and image files:
- <b>Default.aspx</b>(<b>.cs</b>): the Web form of the demo.
- <b>StyleSheet.css</b>: css file for the styles used in the demo.
- <b>web.config</b>: web configuration file.
- <b>js/*</b>: this folder contains all the JavaScript resources needed by the demo.
- <b>images/*</b>: this folder contains image files.
- <b>App_Code/*</b>: this folder contains source code for the xml data source.
- <b>App_Data/*</b>: this folder contains the xml file.

To recompile the provided source, you just need to create a project for a Web Application target, then include the source and include references to the [Microsoft Ajax Toolkit](http://ajaxcontroltoolkit.codeplex.com/releases/) binaries files.
Furthermore, before you can run the demo, some dependencies need to be solved:
- Get the lightstreamer.js file from the [latest Lightstreamer distribution](http://www.lightstreamer.com/download) and put it in the "/js" folder of the demo. Alternatively, you can build a lightstreamer.js file from the [online generator](http://www.lightstreamer.com/distros/Lightstreamer_Allegro-Presto-Vivace_5_1_1_Colosseo_20130305/Lightstreamer/DOCS-SDKs/sdk_client_javascript/tools/generator.html). In that case, be sure to include the LightstreamerClient, Subscription, StaticGrid, Chart, SimpleChartListener, and StatusWidget modules and to use the "Use AMD" version.
- Get the require.js file form the [requirejs.org](http://requirejs.org/docs/download.html) and put it in the "/js" folder of the demo.

# See Also #

## Lightstreamer Adapters needed by these demo clients ##

* [Lightstreamer StockList Demo Adapter](https://github.com/Weswit/Lightstreamer-example-Stocklist-adapter-java)
* [Lightstreamer Reusable Metadata Adapter in Java](https://github.com/Weswit/Lightstreamer-example-ReusableMetadata-adapter-java)

## Similar demo clients that may interest you ##

* [Lightstreamer StockList Demo Client for JavaScript](https://github.com/Weswit/Lightstreamer-example-Stocklist-client-javascript)
* [Lightstreamer StockList Demo Client for jQuery](https://github.com/Weswit/Lightstreamer-example-StockList-client-jquery)
* [Lightstreamer StockList Demo Client for Dojo](https://github.com/Weswit/Lightstreamer-example-StockList-client-dojo)
* [Lightstreamer StockList Demo Client for Adobe Flex SDK](https://github.com/Weswit/Lightstreamer-example-StockList-client-flex)
* [Lightstreamer StockList Demo Client for Java SE](https://github.com/Weswit/Lightstreamer-example-StockList-client-java)
* [Lightstreamer StockList Demo Client for .NET](https://github.com/Weswit/Lightstreamer-example-StockList-client-dotnet)

# Lightstreamer Compatibility Notes #

- Compatible with Lightstreamer JavaScript Client library version 6.0 or newer.