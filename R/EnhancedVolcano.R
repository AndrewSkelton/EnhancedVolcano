EnhancedVolcano <- function(toptable, x, y, xlim = c(min(toptable[,x], na.rm=TRUE), max(toptable[,x], na.rm=TRUE)), ylim = c(0, max(-log10(toptable[,y]), na.rm=TRUE) + 5), xlab = bquote(~Log[2]~ "fold change"), ylab = bquote(~-Log[10]~italic(P)), pCutoff = 0.05, pLabellingCutoff = pCutoff, FCcutoff = 2.0, title = "", titleLabSize = 16, axisLabSize = 16, transcriptPointSize = 0.8, transcriptLabSize = 2.0, col=c("grey30", "forestgreen", "royalblue", "red2"), colAlpha = 1/2, legend=c("NS","Log2 FC","P","P & Log2 FC"), legendPosition = "top", legendLabSize = 10, legendIconSize = 3.0, DrawConnectors = FALSE, widthConnectors = 0.5, colConnectors = "black")
{
	if(!requireNamespace("ggplot2")) { stop( "Please install ggplot2 first.", call.=FALSE) }
	if(!requireNamespace("ggrepel")) { stop( "Please install ggrepel first.", call.=FALSE) }

	requireNamespace("ggplot2")
	requireNamespace("ggrepel")

	toptable <- as.data.frame(toptable)
	toptable$Significance <- "NS"
	toptable$Significance[(abs(toptable[,x]) > FCcutoff)] <- "FC"
	toptable$Significance[(toptable[,y]<pCutoff)] <- "P"
	toptable$Significance[(toptable[,y]<pCutoff) & (abs(toptable[,x])>FCcutoff)] <- "FC_P"
	toptable$Significance <- factor(toptable$Significance, levels=c("NS","FC","P","FC_P"))

	toptable$xvals <- toptable[,x]
	toptable$yvals <- toptable[,y]

	plot <- ggplot2::ggplot(toptable, ggplot2::aes(x=xvals, y=-log10(yvals))) +

		#Add points:
		#	Colour based on factors set a few lines up
		#	'alpha' provides gradual shading of colour
		#	Set size of points
		ggplot2::geom_point(ggplot2::aes(color=factor(Significance)), alpha=colAlpha, size=transcriptPointSize) +

		#Choose which colours to use; otherwise
		ggplot2::scale_color_manual(values=c(NS=col[1], FC=col[2], P=col[3], FC_P=col[4]), labels=c(NS=legend[1], FC=paste(legend[2], sep=""), P=paste(legend[3], sep=""), FC_P=paste(legend[4], sep=""))) +

		#Set the size of the plotting window
		ggplot2::theme_bw(base_size=24) +

		#Modify various aspects of the plot text and legend
		ggplot2::theme(legend.background=ggplot2::element_rect(),
			plot.title=ggplot2::element_text(angle=0, size=titleLabSize, face="bold", vjust=1),

			panel.grid.major=ggplot2::element_blank(),	#Remove gridlines
			panel.grid.minor=ggplot2::element_blank(),	#Remove gridlines

			axis.text.x=ggplot2::element_text(angle=0, size=axisLabSize, vjust=1),
			axis.text.y=ggplot2::element_text(angle=0, size=axisLabSize, vjust=1),
			axis.title=ggplot2::element_text(size=axisLabSize),

			#Legend
			legend.position=legendPosition,
			legend.key=ggplot2::element_blank(),
			legend.key.size=ggplot2::unit(0.5, "cm"),
			legend.text=ggplot2::element_text(size=legendLabSize),
			title=ggplot2::element_text(size=legendLabSize),
			legend.title=ggplot2::element_blank()) +

		#Change the size of the icons/symbols in the legend
		ggplot2::guides(colour = ggplot2::guide_legend(override.aes=list(size=legendIconSize))) +

		#Set x- and y-axes labels
		ggplot2::xlab(xlab) +
		ggplot2::ylab(ylab) +

		#Set the axis limits
		ggplot2::xlim(xlim[1], xlim[2]) +
		ggplot2::ylim(ylim[1], ylim[2]) +

		#Set title
		ggplot2::ggtitle(title) +

		#Add a vertical line for fold change cut-offs
		ggplot2::geom_vline(xintercept=c(-FCcutoff, FCcutoff), linetype="longdash", colour="black", size=0.4) +

		#Add a horizontal line for P-value cut-off
		ggplot2::geom_hline(yintercept=-log10(pCutoff), linetype="longdash", colour="black", size=0.4)

		#Tidy the text labels for a subset of genes
		if (DrawConnectors == TRUE) {
			plot <- plot + ggrepel::geom_text_repel(data=subset(toptable, toptable[,y]<pLabellingCutoff & abs(toptable[,x])>FCcutoff),
				ggplot2::aes(label=rownames(subset(toptable, toptable[,y]<pLabellingCutoff & abs(toptable[,x])>FCcutoff))),
				size = transcriptLabSize,
				segment.color = colConnectors,
				segment.size = widthConnectors,
				vjust = 1.0)
		} else if (DrawConnectors == FALSE) {
			plot <- plot + ggplot2::geom_text(data=subset(toptable, toptable[,y]<pLabellingCutoff & abs(toptable[,x])>FCcutoff),
				ggplot2::aes(label=rownames(subset(toptable, toptable[,y]<pLabellingCutoff & abs(toptable[,x])>FCcutoff))),
				size = transcriptLabSize,
				check_overlap = TRUE,
				vjust = 1.0)
		}

	return(plot)
}