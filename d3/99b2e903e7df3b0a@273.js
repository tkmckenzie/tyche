// https://observablehq.com/@d3/sankey-diagram@273
export default function define(runtime, observer) {
  const main = runtime.module();
  const fileAttachments = new Map([["energy.csv",new URL("./files/d6774e9422bd72369f195a30d3a6b33ff9d41676cff4d89c93511e1a458efb3cfd16cbb7ce3fecdd8dd2466121e10c9bfe57fd73c7520bf358d352a92b898614",import.meta.url)]]);
  main.builtin("FileAttachment", runtime.fileAttachments(name => fileAttachments.get(name)));
  main.variable(observer()).define(["md"], function(md){return(
md`# Sankey Diagram

This [Sankey diagram](https://github.com/d3/d3-sankey) visualizes the flow of energy: *supplies* are on the left, and *demands* are on the right. Links show how varying amounts of energy are converted or transmitted before being consumed or lost. Data: [Department of Energy & Climate Change](http://www.decc.gov.uk/en/content/cms/tackling/2050/calculator_on/calculator_on.aspx) via [Tom Counsell](https://tamc.github.io/Sankey/)
`
)});
  main.variable(observer("viewof edgeColor")).define("viewof edgeColor", ["html","URLSearchParams"], function(html,URLSearchParams){return(
Object.assign(html`<select>
  <option value=input>Color by input
  <option value=output>Color by output
  <option value=path selected>Color by input-output
  <option value=none>No color
</select>`, {
  value: new URLSearchParams(html`<a href>`.search).get("color") || "path"
})
)});
  main.variable(observer("edgeColor")).define("edgeColor", ["Generators", "viewof edgeColor"], (G, _) => G.input(_));
  main.variable(observer("viewof align")).define("viewof align", ["html","URLSearchParams"], function(html,URLSearchParams){return(
Object.assign(html`<select>
  <option value=left>Left-aligned
  <option value=right>Right-aligned
  <option value=center>Centered
  <option value=justify selected>Justified
</select>`, {
  value: new URLSearchParams(html`<a href>`.search).get("align") || "justify"
})
)});
  main.variable(observer("align")).define("align", ["Generators", "viewof align"], (G, _) => G.input(_));
  main.variable(observer("chart")).define("chart", ["d3","width","height","sankey","data","color","format","edgeColor","DOM"], function(d3,width,height,sankey,data,color,format,edgeColor,DOM)
{
  const svg = d3.create("svg")
      .attr("viewBox", [0, 0, width, height]);

  const {nodes, links} = sankey(data);

  svg.append("g")
      .attr("stroke", "#000")
    .selectAll("rect")
    .data(nodes)
    .join("rect")
      .attr("x", d => d.x0)
      .attr("y", d => d.y0)
      .attr("height", d => d.y1 - d.y0)
      .attr("width", d => d.x1 - d.x0)
      .attr("fill", color)
    .append("title")
      .text(d => `${d.name}\n${format(d.value)}`);

  const link = svg.append("g")
      .attr("fill", "none")
      .attr("stroke-opacity", 0.5)
    .selectAll("g")
    .data(links)
    .join("g")
      .style("mix-blend-mode", "multiply");

  if (edgeColor === "path") {
    const gradient = link.append("linearGradient")
        .attr("id", d => (d.uid = DOM.uid("link")).id)
        .attr("gradientUnits", "userSpaceOnUse")
        .attr("x1", d => d.source.x1)
        .attr("x2", d => d.target.x0);

    gradient.append("stop")
        .attr("offset", "0%")
        .attr("stop-color", d => color(d.source));

    gradient.append("stop")
        .attr("offset", "100%")
        .attr("stop-color", d => color(d.target));
  }

  link.append("path")
      .attr("d", d3.sankeyLinkHorizontal())
      .attr("stroke", d => edgeColor === "none" ? "#aaa"
          : edgeColor === "path" ? d.uid 
          : edgeColor === "input" ? color(d.source) 
          : color(d.target))
      .attr("stroke-width", d => Math.max(1, d.width));

  link.append("title")
      .text(d => `${d.source.name} → ${d.target.name}\n${format(d.value)}`);

  svg.append("g")
      .attr("font-family", "sans-serif")
      .attr("font-size", 10)
    .selectAll("text")
    .data(nodes)
    .join("text")
      .attr("x", d => d.x0 < width / 2 ? d.x1 + 6 : d.x0 - 6)
      .attr("y", d => (d.y1 + d.y0) / 2)
      .attr("dy", "0.35em")
      .attr("text-anchor", d => d.x0 < width / 2 ? "start" : "end")
      .text(d => d.name);

  return svg.node();
}
);
  main.variable(observer("sankey")).define("sankey", ["d3","align","width","height"], function(d3,align,width,height)
{
  const sankey = d3.sankey()
      .nodeId(d => d.name)
      .nodeAlign(d3[`sankey${align[0].toUpperCase()}${align.slice(1)}`])
      .nodeWidth(15)
      .nodePadding(10)
      .extent([[1, 5], [width - 1, height - 5]]);
  return ({nodes, links}) => sankey({
    nodes: nodes.map(d => Object.assign({}, d)),
    links: links.map(d => Object.assign({}, d))
  });
}
);
  main.variable(observer("format")).define("format", ["d3","data"], function(d3,data)
{
  const format = d3.format(",.0f");
  return data.units ? d => `${format(d)} ${data.units}` : format;
}
);
  main.variable(observer("color")).define("color", ["d3"], function(d3)
{
  const color = d3.scaleOrdinal(d3.schemeCategory10);
  return d => color(d.category === undefined ? d.name : d.category);
}
);
  main.variable(observer("data")).define("data", ["d3","FileAttachment"], async function(d3,FileAttachment)
{
  const links = d3.csvParse(await FileAttachment("energy.csv").text(), d3.autoType);
  const nodes = Array.from(new Set(links.flatMap(l => [l.source, l.target])), name => ({name, category: name.replace(/ .*/, "")}));
  return {nodes, links, units: "TWh"};
}
);
  main.variable(observer("width")).define("width", function(){return(
954
)});
  main.variable(observer("height")).define("height", function(){return(
600
)});
  main.variable(observer("d3")).define("d3", ["require"], function(require){return(
require("d3@5", "d3-sankey@0.12")
)});
  return main;
}
