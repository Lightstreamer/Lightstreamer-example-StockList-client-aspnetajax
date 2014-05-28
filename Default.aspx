<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">


<!--
LIGHTSTREAMER - www.lightstreamer.com
3D World Demo
Copyright 2013 Weswit s.r.l.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->


<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Lightstreamer ASP.NET AJAX Demo</title>
    <link href="StyleSheet.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="js/require.js"></script>
    <script type="text/javascript" src="js/lightstreamer.js"></script>
    <script type="text/javascript">

        var names = [];
        var charts = [];
        var grids = [];
        var subs = [];

        var onLoad, newChart, newSimpleC;

        require(["js/lsClient", "Subscription", "StaticGrid", "Chart", "SimpleChartListener"], function (lsClient, Subscription, StaticGrid, Chart, SimpleChartListener) {
            onLoad = function () {
                var ik;
                for (ik = 1; ik < 9; ik++) {
                    grids[ik] = new StaticGrid(ik, true);
                    var itemLists = grids[ik].extractItemList();
                    var fieldLists = grids[ik].extractFieldList();

                    grids[ik].setSort("stock_name");
                    grids[ik].setNodeTypes(["div", "span", "img", "a"]);
                    grids[ik].setAutoCleanBehavior(true, false);

                    subs[ik] = new Subscription("MERGE", itemLists, fieldLists);
                    subs[ik].addListener({
                        onItemUpdate: function (itemUpdate) {
                            if (itemUpdate.isValueChanged("stock_name")) {
                                names[itemUpdate.getItemName().substring(4)] = itemUpdate.getValue("stock_name");
                            }
                        }
                    });
                    subs[ik].addListener(grids[ik]);
                    subs[ik].setDataAdapter("QUOTE_ADAPTER");
                    subs[ik].setRequestedSnapshot("yes");
                    subs[ik].setRequestedMaxFrequency(1);

                    lsClient.subscribe(subs[ik]);
                }

                openAChart(2);
                openAChart(7);
            }

            newChart = function (itemId) {
                return new Chart("graph" + itemId, true);
            }

            newSimpleC = function () {
                return new SimpleChartListener();
            }

            addChartToSub = function (itemId) {

            }
        });

        //////////////////Tables conf
        //called by atlas at page onload event
        function pageLoad() {
            onLoad();
        }

        var itemChartLines = {};

        function createChart(chartItem) {
            charts[chartItem] = newChart(chartItem);
            charts[chartItem].configureArea("lsgbox", 200, 200, 10, 50);
            charts[chartItem].setXAxis("time", function (stringDate) {
                stringDate = new String(stringDate);
                i1 = stringDate.indexOf(':');
                i2 = stringDate.lastIndexOf(':');
                return (stringDate.substring(0, i1) * 3600 + stringDate.substring(i1 + 1, i2) * 60 + stringDate.substring(i2 + 1, stringDate.length) * 1);
            });

            charts[chartItem].addYAxis("last_price", function (yValue) {
                var y = new String(yValue);
                if (y.indexOf(",") > -1) {
                    var y = y.replace(",", ".");
                }
                return new Number(y);
            });
            charts[chartItem].setXLabels(4, "lslblx", labelFormatterX.formatValue);

            charts[chartItem].addListener(newSimpleC);
            charts[chartItem].addListener({
                onNewLine: function (key, newChartLine, nowX, nowY) {
                    var draggableChart = document.getElementById("titlegraph" + key.substring(4)).innerHTML = names[key.substring(4)];

                    newChartLine.setYLabels(4, "lslbly", labelFormatterY.formatValue);

                    // Y axis range.
                    var minY = nowY * 0.9;
                    var maxY = nowY * 1.1;
                    newChartLine.positionYAxis(minY, maxY);

                    // X axis range.
                    var maxX = getSeconds(nowX) + 300;
                    var minX = getSeconds(nowX);
                    charts[chartItem].positionXAxis(minX, maxX);
                }
            });

            subs[chartItem].addListener(charts[chartItem]);

            charts[chartItem].updateRow(subs[chartItem].getItems()[0], { "last_price": subs[chartItem].getValue(1, "last_price"), "time": subs[chartItem].getValue(1, "time") });
        }

        ///////////Format functions

        var labelFormatterX = {};
        labelFormatterX.formatValue = function (val) {
            return formatTime(getTime(val));
        }

        var labelFormatterY = {};
        labelFormatterY.formatValue = function (val) {
            return formatDecimal(val, 2, true);
        }

        function getSeconds(stringDate) {
            stringDate = new String(stringDate);
            i1 = stringDate.indexOf(':');
            i2 = stringDate.lastIndexOf(':');
            return (stringDate.substring(0, i1) * 3600 + stringDate.substring(i1 + 1, i2) * 60 + stringDate.substring(i2 + 1, stringDate.length) * 1);
        }

        function formatDecimal(value, decimals, keepZero) {
            var mul = new String("1");
            var zero = new String("0");
            for (var i = decimals; i > 0; i--) {
                mul += zero;
            }
            value = Math.floor(value * mul);
            value = value / mul;
            var strVal = new String(value);
            if (!keepZero) {
                return strVal;
            }

            var nowDecimals = 0;
            var dot = strVal.indexOf(".");
            if (dot == -1) {
                strVal += ".";
            } else {
                nowDecimals = strVal.length - dot - 1;
            }
            for (var i = nowDecimals; i < decimals; i++) {
                strVal = strVal + zero;
            }
            return strVal;
        }

        function formatTime(val) {
            var a = new Number(val.substring(0, val.indexOf(":")));
            if (a > 12) {
                a -= 12;
            }
            var b = val.substring(val.indexOf(":"), val.length);
            return a + b;
        }

        function getTime(secondsStr) {
            var hours = Math.floor(secondsStr / (60 * 60));
            var seconds = secondsStr - (hours * (60 * 60));
            var minutes = Math.floor(seconds / 60);
            var seconds = Math.round(seconds - (minutes * 60));

            if (minutes.toString().length < 2) {
                minutes = ":0" + minutes;
            } else {
                minutes = ":" + minutes;
            }

            if (seconds.toString().length < 2) {
                seconds = ":0" + seconds;
            } else {
                seconds = ":" + seconds;
            }

            return hours + minutes + seconds;
        }

        //////////////////////Chart UI  

        var draggableCounter = 0;

        function openAChart(itemId) {
            var draggableChart = document.getElementById("chart_" + itemId);
            if (!draggableChart) {

                draggableChart = document.createElement("div");
                draggableChart.id = "chart_" + itemId;
                draggableChart.className = "chartContainer";
                nextInnerHTML = "<table style='width:100%'><tr><td>";
                nextInnerHTML += '<div id="titlegraph' + itemId + '" class="chartHeader">-</div>';
                nextInnerHTML += "</td><td>";
                nextInnerHTML += '<div class="chartButton"><a class="chartButtonLink" href="#" onclick="closeChart(' + itemId + ')">X</a></div>';
                nextInnerHTML += "</td></tr><tr><td colspan=2>";
                nextInnerHTML += '<div data-source="lightstreamer" id="graph' + itemId + '" ></div>';
                nextInnerHTML += "</td></tr></table>";

                draggableChart.innerHTML = nextInnerHTML;

                var distance = ((itemId - 1) * 20) + "px";
                draggableChart.style.position = "relative";
                draggableChart.style.top = distance;
                draggableChart.style.left = distance;

                document.getElementById("appendHereCharts").appendChild(draggableChart);

                //New ASP.NET AJAX code: 
                Sys.Application.add_init(function () { $create(AjaxControlToolkit.FloatingBehavior, { "handle": $get('chart_' + itemId), "id": "DragPanelExtender" + draggableCounter++ }, null, null, $get('chart_' + itemId)); });

                createChart(itemId);
            } else {
                alert("This chart is already open!");
            }
        }

        function closeChart(itemId) {
            var draggableChart = document.getElementById("chart_" + itemId);
            if (!draggableChart) {
                alert("This chart is already closed!");
            } else {
                subs[itemId].removeListener(charts[itemId]);
                draggableChart.parentNode.removeChild(draggableChart);
                delete (draggableChart);
                charts[itemId] = null;
            }
        }

    </script>
</head>

<body>
<a href="https://github.com/Weswit/Lightstreamer-example-StockList-client-aspnetajax"><img style="position: absolute; top: 0; right: 0; border: 0; z-index:1" src="https://s3.amazonaws.com/github/ribbons/forkme_right_darkblue_121621.png" alt="Fork me on GitHub"></a>
<table class="demoTitle" style="width:100%">
<tr>
<td><a href="http://www.lightstreamer.com"><img style="border-width:0; left: 25px; width: 228px;" src="images/logo.png" /></a></td>
<td><div class="demoTitle">Lightstreamer ASP.NET AJAX Demo</div></td>
<td><a href="http://ajax.asp.net"><img style="border-width:0; height: 98px; width: 137px;" src="images/asplogo.jpg" /></a></td>
</tr>
</table>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
            <table style="width: 100%">
            <tr>
                <td style="width: 50%;">
                    <div class="demoarea">
                       <div class="demoheading">ReorderList Demonstration</div>
                       <asp:UpdatePanel ID="up1" runat="server">
                            <ContentTemplate>
                            	<div style="text-align:right;font-size:9px;">GMT+01:00 timezone used&nbsp;</div>
                                <div class="reorderListDemo">
                                    <ul>
                                    <li style="vertical-align:middle;">
	                                    <table border="0" style="border-width:0px;border-collapse:collapse;">
		                                    <tr>
			                                    <td>
					                                    <div>
						                                    <div class="fakeDragHandle"></div>
					                                    </div>
			                                    </td>
			                                    <td style="width: 100%;">
                                                    <div class="itemArea">
                                                    <table style="width:100%">
                                                        <tbody>
                                                            <tr>
                                                                <td class="stockTD"><span><div>Stock</div></span></td>
                                                                <td class="priceTD"><span><div>Price</div></span></td>
                                                                <td class="timeTD"><span><div>Time</div></span></td>
                                                                <td></td>
                                                            </tr>
                                                        </tbody>
                                                     </table>
                                                     </div>
                                                </td>
		                                    </tr>
	                                    </table>
                                    </li>
                                    </ul>

                                  <ajaxToolkit:ReorderList  ID="ReorderList1" runat="server" DataSourceID="ObjectDataSource1"
                                    DragHandleAlignment="Left" ItemInsertLocation="Beginning" DataKeyField="ItemID" SortOrderField="Priority">
                                        <ItemTemplate>
                                            <div class="itemArea">
                                                <table style="width:100%">
                                                <tr>
                                                    <td class="stockTD"><asp:Label ID="Label1" runat="server" Text='<%# "<div onclick=\"openAChart("+HttpUtility.HtmlEncode(Convert.ToString(Convert.ToInt32(Eval("ItemID"))+1))+")\" class=\"clickable\"><div data-source=\"lightstreamer\" data-grid=\""+HttpUtility.HtmlEncode(Convert.ToString(Convert.ToInt32(Eval("ItemID"))+1))+"\" data-item=\"item"+HttpUtility.HtmlEncode(Convert.ToString(Convert.ToInt32(Eval("ItemID"))+1))+"\" data-field=\"stock_name\">"+HttpUtility.HtmlEncode(Convert.ToString(Convert.ToInt32(Eval("ItemID"))+1))+"</div></div>" %>'></asp:Label></td>
                                                    <td class="priceTD"><asp:Label ID="Label2" runat="server" Text='<%# "<div data-source=\"lightstreamer\" data-grid=\""+HttpUtility.HtmlEncode(Convert.ToString(Convert.ToInt32(Eval("ItemID"))+1))+"\" data-item=\"item"+HttpUtility.HtmlEncode(Convert.ToString(Convert.ToInt32(Eval("ItemID"))+1))+"\" data-field=\"last_price\">-</div>" %>'></asp:Label></td>
                                                    <td class="timeTD"><asp:Label ID="Label3" runat="server" Text='<%# "<div data-source=\"lightstreamer\" data-grid=\""+HttpUtility.HtmlEncode(Convert.ToString(Convert.ToInt32(Eval("ItemID"))+1))+"\" data-item=\"item"+HttpUtility.HtmlEncode(Convert.ToString(Convert.ToInt32(Eval("ItemID"))+1))+"\" data-field=\"time\">-</div>" %>'></asp:Label></td>
                                                    <td></td>
                                                </tr>
                                                </table>
                                            </div>
                                        </ItemTemplate>
                                        <ReorderTemplate>
                                            <asp:Panel ID="Panel2" runat="server" CssClass="reorderCue">
                                            </asp:Panel>
                                        </ReorderTemplate>
                                        <DragHandleTemplate>
                                            <div class="dragHandle"></div>
                                        </DragHandleTemplate>
                                    </ajaxToolkit:ReorderList>
                                </div>
                            
                                <asp:ObjectDataSource ID="ObjectDataSource1" runat="server" DeleteMethod="Delete"
                                    InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="Select"
                                    TypeName="SessionTodoXmlDataObject" UpdateMethod="Update">
                                    <DeleteParameters>
                                        <asp:Parameter Name="Original_ItemID" Type="Int32" />
                                    </DeleteParameters>
                                    <UpdateParameters>
                                        <asp:Parameter Name="Title" Type="String" />
                                        <asp:Parameter Name="Description" Type="String" />
                                        <asp:Parameter Name="Priority" Type="Int32" />
                                        <asp:Parameter Name="Original_ItemID" Type="Int32" />
                                    </UpdateParameters>
                                    <InsertParameters>
                                        <asp:Parameter Name="Title" Type="String" />
                                        <asp:Parameter Name="Description" Type="String" />
                                        <asp:Parameter Name="Priority" Type="Int32" />
                                    </InsertParameters>
                                </asp:ObjectDataSource>
                            </ContentTemplate>     
                     </asp:UpdatePanel>
                  </div>
                  </td>
                  <td>
                    <div id="appendHereCharts">
                    </div>
                   
                  </td>
                </tr>
                <tr>
                    <td>
                        <div class="explanation">
                            <asp:UpdatePanel ID="DescriptionDemoHead" runat="server">
                            <ContentTemplate>
                                <asp:Panel ID="pHeader" runat="server" CssClass="cpHeader">
                                    <div>
                                        <asp:Image ID="ImageColExp" runat="server" ImageUrl="~/images/collapse.jpg" />&nbsp;
                                        <asp:Label ID="lblText" runat="server" />
                                    </div>
                                </asp:Panel>
                                <asp:Panel ID="pBody" runat="server" CssClass="cpBody">
                                      <div>
                                        Drag the blue handles above to change the positions of rows.<br />
                                        Click on stock names to open a streaming chart.<br />
                                        Drag around and close any opened popup chart.<br />
                                    </div>
                                </asp:Panel>
 
                                <ajaxToolkit:CollapsiblePanelExtender ID="CollapsiblePanelExtender1" runat="server" 
                                  TargetControlID="pBody" 
                                  CollapseControlID="pHeader" 
                                  ExpandControlID="pHeader"
                                  Collapsed="False" 
                                  TextLabelID="lblText" 
                                  CollapsedText="<b>Demo explanation ... </b>" 
                                  ExpandedText="<b>Demo explanation:</b>"
                                  ImageControlID="ImageColExp"
                                  ExpandedImage="~/images/collapse.jpg"
                                  CollapsedImage="~/images/expand.jpg"
                                  CollapsedSize="0">
                                </ajaxToolkit:CollapsiblePanelExtender>
                             </ContentTemplate>
                        </asp:UpdatePanel>
                       </div>
                    </td>
                </tr>
            </table>
            <asp:Panel runat="server" ID="UselessPanel1"><asp:Panel runat="server" ID="UselessPanel2">&nbsp;</asp:Panel>&nbsp;</asp:Panel>
            <ajaxToolkit:DragPanelExtender ID="UselessDPE" runat="server"  TargetControlID="UselessPanel1" DragHandleID="UselessPanel2" />
        </form>    
</body>
</html>
