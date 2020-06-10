// !preview r2d3 data=read.csv("barchart_data.csv")

console.log("Made it here");

var barHeight = Math.floor(height / data.length);

svg.selectAll('rect')
  .data(data)
  .enter().append('rect')
    .attr('width', calculate_width)
    .attr('height', barHeight)
    .attr('y', function(d, i) { return i * barHeight; })
    .attr('fill', 'steelblue');

function calculate_width(d, i){
	return d.value * width;
}
