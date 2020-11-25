### Lorenz curves

# We can calculate standard measures of inequality in our population, helping us to compare our results against the data. The code below calculates the Lorenz curve for consumption in our economy.

function Lorenz(ϕ,values)

    L = [values[1:k]'*ϕ[1:k] for k in 1:n_grid]
    return L./L[n_grid]
end


### Gini coefficients

# We can also calculate gini coefficients:

function gini(pdf,values)
        
    n = size(pdf)[1]

    μ = pdf'*values

    g = 100*(1/(2*μ))*sum([pdf[i]*pdf[j]*abs(values[i]-values[j]) for i in 1:n, j in 1:n])

    return g[1]
end


### Generating PDFs over a uniform grid

# The distribution solver above generates probability density functions for the population wealth, but these pdfs are scaled over the asset grid. This is fine for lots of calculations, as long as we are working with consistent grids, but it will skew any plot of the raw pdf. So, in order to plot our results, we need a way to rescale our pdf. The code below just generates a new pdf from an existing cdf and an associated grid.

# (there is probably a smarter way to do this, but meanwhile...)

function genpdf(cdf,grid)
    
    n      = size(grid)[1]
    pdf    = zeros(n)
    pdf[1] = (cdf[2] - cdf[1])/(grid[2]-grid[1])
    
    for k in 2:n-1
        
        pdf[k] = (cdf[k+1] - cdf[k-1])/(grid[k+1]-grid[k-1])

    end
        
    pdf[n] = (cdf[n] - cdf[n-1])/(grid[n]-grid[n-1])
    
    return pdf./sum(pdf)
end          