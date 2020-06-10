// !preview r2d3 data=read.csv("energy.csv"), dependencies=c(paste0(.libPaths()[1], "/r2d3/www/d3-sankey/d3-sankey.js"), "d3-jetpack")

alert("Script started.");

//const {DOM} = new observablehq.Library;

const align = "justify";
const edgeColor = "path";

const links_raw = data;
const nodes_raw = Array.from(new Set(links_raw.flatMap(l => [l.source, l.target])), name => ({name: name, category: name.replace(/ .*/, "")}));
const data_raw = {nodes: nodes_raw.map(d => Object.assign({}, d)), links: links_raw.map(d => Object.assign({}, d)), units: "TWh"};

const sankey = d3.sankey()
  .nodeId(d => d.name)
  .nodeAlign(d3[`sankey${align[0].toUpperCase()}${align.slice(1)}`])
  .nodeWidth(15)
  .nodePadding(10)
  .extent([[1, 5], [width - 1, height - 5]]);

const {nodes, links} = sankey(data_raw);

alert("Made it here.");

g = svg.append("g")
		.attr("stroke", "#000")
	.selectAll("rect")
	.data(nodes)
	.enter().append("rect")
		.attr("x", d => d.x0)
		.attr("y", d => d.y0)
		.attr("height", d => d.y1 - d.y0)
		.attr("width", d => d.x1 - d.x0)
		.attr("fill", color)
	.append("title")
		.text(d => `${d.name}\n${format(d.value)}`);

alert(g.attr("fill"));

const link = svg.append("g")
		.attr("fill", "none")
		.attr("stroke-opacity", 0.5)
	.selectAll("g")
	.data(links)
	.enter().append("g")
		.style("mix-blend-mode", "multiply");

if (edgeColor === "path"){
  const gradient = link.append("linearGradient")
	  	.attr("id", d => (d.uid = Date.now()))
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

alert(color(links[1].source));

link.append("title")
		.text(d => `${d.source.name} -> ${d.target.name}\n${format(d.value)}`);

svg.append("g")
		.attr("font-family", "sans-serif")
		.attr("font-size", 10)
	.selectAll("text")
	.data(nodes)
	.enter().append("text")
		.attr("x", d => d.x0 < width / 2 ? d.x1 + 6 : d.x0 - 6)
		.attr("y", d => (d.y1 + d.y0) / 2)
		.attr("dy", "0.35em")
		.attr("text-anchor", d => d.x0 < width / 2 ? "start" : "end")
		.text(d => d.name);

function format(d){
	const format = d3.format(",.0f");
	return data.units ? d => `${format(d)} ${data.units}`: format;
}

function color(d){
	const color = d3.scaleOrdinal(d3.schemeCategory10);
	return d => color(d.category === undefined ? d.name : d.category);
}
