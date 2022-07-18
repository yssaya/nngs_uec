/* $Id: mlr.h,v 1.2 2002/01/27 16:02:55 pem Exp $
**
** Per-Erik Martin (pem@pem.nu) 1997-12.
**
** The Maximum Likelihood rating algorithm.
**
**   Copyright (C) 1998-2002  Per-Erik Martin
**
**   This program is free software; you can redistribute it and/or modify
**   it under the terms of the GNU General Public License as published by
**   the Free Software Foundation; either version 2 of the License, or
**   (at your option) any later version.
**
**   This program is distributed in the hope that it will be useful,
**   but WITHOUT ANY WARRANTY; without even the implied warranty of
**   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**   GNU General Public License for more details.
**
**   You should have received a copy of the GNU General Public License
**   along with this program; if not, write to the Free Software
**   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
*/

#ifndef _mlr_h
#define _mlr_h

#include <stdio.h>

/* The magic constant. */
extern double Mlrate_s;

/* Compute the ratings. */
extern void mlrate(double mean, FILE *fdiag);

/* Compute the errors (called after mlrate()). */
extern void mlrate_errors(FILE *fdiag);

#endif /* _mlr_h */
