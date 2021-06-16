```math
R T + \vec{x}
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