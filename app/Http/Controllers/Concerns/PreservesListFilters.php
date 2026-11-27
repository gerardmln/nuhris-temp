<?php

namespace App\Http\Controllers\Concerns;

use Illuminate\Http\Request;

trait PreservesListFilters
{
    /**
     * @param  array<int, string>  $keys
     * @return array<string, mixed>
     */
    protected function listFilterQuery(Request $request, array $keys): array
    {
        return array_filter(
            array_intersect_key($request->query(), array_flip($keys)),
            'is_scalar'
        );
    }
}
