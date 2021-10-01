# "Toy" Data
Waterfall.jl provides methods to generate random distributions of randomly correlated data points to provide "toy" data for development purposes.
This aides in waterfall plot development to assess the challenges of using waterfall plots to visualize correlated investments with uncertain impacts.

## Random Correlation
Waterfall.jl includes methods to correlate input data by replacing each data point by a random uniform or normal distribution centered at its value, and, if desired, adding random correlation to the sets of samples.

Given uncorrelated, singular data points for each investment, Waterfall.jl has the capability to add a random (or specified) number of random correlations between random sets of investments.

This is done by applying a rotation matrix ``R \in \mathbb{R}^{N\times N}`` to the input values, where ``N`` is the number of investments.

The elements of ``R`` can be defined:

```math
R_{i,j}(r_{min}, r_{max}) \sim U(-r_i,r_i)
,\;\text{where}\;
    |r_i| \sim U(r_{min},r_{max})
```

The correlation values ``|r|`` are defined from a random **uniform distribution** on the interval ``U(r_{min},r_{max})``, with an equal (``\pm 1``) number of positive and negative values.

## Random Samples
Waterfall.jl also provides the option to add uncertainty to input values by translating the input by ``\pm`` a uniform or normal distribution.
This is accomplished using a translation function, ``t(x_{i}; t_min, t_max) \in \mathbb{R}^{N \times S}`` to the input values ``x \in \mathbb{R}^{N\times 1}``, where ``N`` is the number of investments and ``S`` is the number of samples.
This can be defined using either a normal distribution, ``N(x_{i}, t_{i})``, or a uniform distribution, ``U(x_{i}-t_{i}, x_{i}+t_{i})``:

```math
\begin{aligned}
t(x_{i}; t_min, t_max) &\sim N(x_{i}, t)
,\;\text{where}\;
    t \sim U(t_{min}, t_{max})
\\&\\
t(x_{i}; t_min, t_max) &\sim U(x_{i}-t, x_{i}+t)
,\;\text{where}\;
    t \sim U(t_{min}, t_{max})
\end{aligned}
```

To apply both the random translation (for uncertainty) and rotation (for correlation):

```math
x_{i,j} = R(r_{min}, r_{max}) \cdot t(x_{i}; t_min, t_max)
```