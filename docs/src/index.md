```@docs
Waterfall.Data
```

Cumulative value

```math
\vec{v}' = (L + c I) \vec{v}
\\\\
\begin{aligned}
\vec{v}_{beg} &= (L - I) \vec{v}
\\
\vec{v}_{end} &= L \vec{v}
\end{aligned}
```

Cumulative x-position

```math
w_{sample} = \dfrac{w_{step}}{N_{sample}}
\\
\vec{w}_{step} = 
\\
\vec{w}_{sample} = 
\\
\vec{\delta w}_{step}
```

Calculate ``x``-position:

```math
\begin{aligned}
\vec{\delta x} &= \vec{w}_{sample} \left( U + shift \cdot I\right)
\\
\vec{x} &= \left(L-I\right) \vec{w}_{step} + L \vec{\delta w}_{step} + extend + \vec{\delta x}
\end{aligned}
```


```math
\begin{aligned}
R &= I
\\
R_{i,j} &= R_{j,i} = x
,\;\text{where}\;
\left\{ x \;\big\vert\; |x| \in \left[ x_{min},x_{max} \right],\, x\in\mathbb{R}^{N} \right\}
\end{aligned}
```


random_translation(dim, N; distribution, fuzziness)

_random_translation(dim, N, distribution, offset)